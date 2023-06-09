import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:yavc/presentation/state.dart';

import '../database/db.dart';
import 'constants.dart';

class ParsingResult {
  String name;
  List<String> labels;
  String developer;
  String version;
  Uint8List banner;
  List<String> tags;
  String description;
  String lastUpdated;
  ParsingResult(
    this.name,
    this.labels,
    this.developer,
    this.version,
    this.banner,
    this.tags,
    this.description,
    this.lastUpdated,
  );
}

String? getThreadAttr(List<String> names, String plain) {
  for (var name in names) {
    var regex = RegExp(
      r'^ *' + name + r' *(?: *\n? *:|: *\n? *) *(.*)',
      multiLine: true,
      caseSensitive: false,
    );
    var matches = regex.allMatches(plain);
    if (matches.isNotEmpty) {
      return matches.first.group(1);
    }
  }
  return null;
}

Future<ParsingResult> parseThread(int threadId, {bool noBanner = false}) async {
  Uri url = Uri.parse('https://f95zone.to/threads/$threadId');

  Response response = await get(url);

  int status = response.statusCode;

  if (status == 404) {
    throw ('Thread not found!');
  }
  if (status == 403) {
    throw ("Thread is not supported.\nYou can only add threads from: ${supportedForums.join(', ')}");
  }
  if (status != 200) {
    throw ('Failed to retrieve data (status code: $status)');
  }

  Document document = parse(response.body);
  String plain = response.body
      .replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true), '');

  // Checking if forum is supported

  List<Element> breadcrumbs = document.getElementsByClassName('p-breadcrumbs');

  if (breadcrumbs.isEmpty) {
    throw ('Failed to determine thread type');
  }

  List<Element> breadcrumbsSpan = breadcrumbs[0].getElementsByTagName('span');

  if (breadcrumbsSpan.isEmpty) {
    throw ('Failed to determine thread type');
  }

  String forum = breadcrumbsSpan.last.text.trim();

  if (!supportedForums.contains(forum)) {
    throw ("Forum '$forum' is unsupported.\nYou can only add threads from: ${supportedForums.join(', ')}");
  }

  // Requesting version

  Response versionResponse =
      await get(Uri.parse(fastCheckEndpoint + threadId.toString()));

  Map<String, dynamic> json = jsonDecode(versionResponse.body);

  if (versionResponse.statusCode != 200) {
    if (json['status'] == null || json['msg']) {
      throw ('Failed to get version (status code: ${versionResponse.statusCode})');
    } else {
      throw ("Failed to get version (reason: ${json['msg']})");
    }
  }

  String version = json['msg'][threadId.toString()];

  // Parsing key elements

  List<Element> threadStarter =
      document.getElementsByClassName('message-threadStarterPost');

  if (threadStarter.isEmpty) {
    throw ('Thread appears empty somehow o_0');
  }

  List<Element> titleGroup = document.getElementsByClassName('p-title-value');

  if (titleGroup.isEmpty) {
    throw ('Failed to locate thread title');
  }

  // Parsing name, developer and labels

  List<String> labels = titleGroup[0]
      .getElementsByTagName('a')
      .where((el) => el.className == 'labelLink')
      .map((el) => el.text)
      .toList();

  String titleSlug = titleGroup[0].text;

  for (var label in labels) {
    titleSlug = titleSlug.replaceFirst(label, '').trim();
  }

  String developer;
  final regexp = RegExp(r'\[(.*?)\]');
  final matches = regexp.allMatches(titleSlug);
  if (matches.isNotEmpty) {
    developer = matches.last.group(1) ?? '';
  } else {
    developer = '';
  }

  String title = titleSlug.replaceAll(regexp, '').trim();

  // Parsing tags

  List<String> tags = document
      .getElementsByTagName('a')
      .where((el) => el.className == 'tagItem')
      .map((el) => el.text)
      .toList();

  // Parsing post info

  String description = '';
  String lastUpdated = '';

  List<Element> postWrappers = threadStarter[0]
      .getElementsByTagName('div')
      .where((el) => el.className == 'bbWrapper')
      .toList();

  if (postWrappers.isNotEmpty) {
    Element wrapper = postWrappers[0];

    List<Element> wrapperDivs = wrapper.getElementsByTagName('div');
    if (wrapperDivs.isNotEmpty) {
      description =
          wrapperDivs[0].text.trim().replaceAll(RegExp('Overview:*\n*'), '');
    }

    var lastUpdatedAttrResult = getThreadAttr(lastUpdatedAttrNames, plain);
    if (lastUpdatedAttrResult != null) {
      lastUpdated = lastUpdatedAttrResult;
    }
  }

  Uint8List banner = Uint8List(0);

  if (!noBanner) {
    // Downloading banner

    List<Element> bannerEl = threadStarter[0].getElementsByClassName('bbImage');

    if (bannerEl.isEmpty) {
      throw ('Failed to locate banner image');
    }

    String? bannerUrl = bannerEl[0].attributes['src'];

    if (bannerUrl == null) {
      throw ('Malformed banner attributes');
    } else {
      String fullSizeUrl = bannerUrl.replaceAll('thumb/', '');
      Response bannerResponse = await get(Uri.parse(fullSizeUrl));
      banner = bannerResponse.bodyBytes;
    }
  }

  return ParsingResult(
    title,
    labels,
    developer,
    version,
    banner,
    tags,
    description,
    lastUpdated,
  );
}

Future<ParsingResult> parseThreadNoBanner(int threadId) async {
  var result = await parseThread(threadId, noBanner: true);
  return result;
}

class UpdateResult {
  List<String> failed;
  UpdateResult(this.failed);
}

Future<UpdateResult> refresh(WidgetRef ref) async {
  final database = ref.read(AppDatabase.provider);
  final threads = await database.threads.all().get();

  // sanity check
  if (threads.isEmpty) {
    return UpdateResult([]);
  }

  List<String> failed = [];

  threads.retainWhere((t) => !t.archived);

  List<String> ids = threads.map((t) => t.id.toString()).toList();

  Response versionResponse =
      await get(Uri.parse(fastCheckEndpoint + ids.join(',')));

  Map<String, dynamic> json = jsonDecode(versionResponse.body);

  if (versionResponse.statusCode != 200) {
    if (json['status'] == null || json['msg']) {
      throw ('Request to endpoint failed (status code: ${versionResponse.statusCode})');
    } else {
      throw ("Request to endpoint failed (reason: ${json['msg']})");
    }
  }

  List<Thread> newThreads = [];

  int counter = 0;
  int refreshQueue = threads.length;
  DateTime timeNow = DateTime.now();

  for (var thread in threads) {
    int daysSinceLastFullRefresh = timeNow
        .difference(DateTime.fromMillisecondsSinceEpoch(thread.lastFullRefresh))
        .inDays;
    String? version = json['msg'][thread.id.toString()];

    if (version == null) {
      failed.add('${thread.name} (${thread.id})');
      counter++;
      ref.read(refreshProgressProvider.notifier).state = counter / refreshQueue;
      continue;
    }

    if (daysSinceLastFullRefresh >= 7 || thread.prevVersion != version) {
      try {
        var result = await compute(parseThreadNoBanner, thread.id);
        newThreads.add(thread.copyWith(
            name: result.name,
            labels: result.labels,
            developer: result.developer,
            currVersion: version,
            tags: result.tags,
            description: result.description,
            lastUpdated: result.lastUpdated,
            lastFullRefresh: timeNow.millisecondsSinceEpoch));
      } catch (e) {
        failed.add('${thread.name} (${thread.id}) (full recheck)');
      } finally {
        await Future.delayed(const Duration(seconds: 1));
      }
    } else {
      newThreads.add(thread.copyWith(currVersion: version));
    }
    counter++;
    ref.read(refreshProgressProvider.notifier).state = counter / refreshQueue;
  }

  await database.updateThreads(newThreads);

  ref.read(refreshProgressProvider.notifier).state = 0.0;

  return UpdateResult(failed);
}
