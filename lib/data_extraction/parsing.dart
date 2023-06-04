import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../database/db.dart';

const String fastCheckEndpoint = 'https://f95zone.to/sam/checker.php?threads=';

final List<String> supportedForums = [
  'Games',
  'Comics & Stills',
  'Animations & Loops'
];

class ParsingResult {
  String name;
  List<String> labels;
  String developer;
  String version;
  Uint8List banner;
  ParsingResult(
      this.name, this.labels, this.developer, this.version, this.banner);
}

Future<ParsingResult> parseThread(int threadId) async {
  Uri url = Uri.parse('https://f95zone.to/threads/$threadId');

  Response response = await get(url);

  int status = response.statusCode;

  if (status == 404) {
    throw ('Thread not found!');
  }
  if (status == 403) {
    throw ("Thread is unsupported.\nYou can only add threads from: ${supportedForums.join(', ')}");
  }
  if (status != 200) {
    throw ('Failed to retrieve data (status code: $status)');
  }

  Document document = parse(response.body);

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

  // Downloading banner

  List<Element> bannerEl = threadStarter[0].getElementsByClassName('bbImage');

  if (bannerEl.isEmpty) {
    throw ('Failed to locate banner image');
  }

  String? bannerUrl = bannerEl[0].attributes['src'];

  Uint8List banner;

  if (bannerUrl == null) {
    throw ('Malformed banner attributes');
  } else {
    String fullSizeUrl = bannerUrl.replaceAll('thumb/', '');
    Response bannerResponse = await get(Uri.parse(fullSizeUrl));
    banner = bannerResponse.bodyBytes;
  }

  return ParsingResult(title, labels, developer, version, banner);
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

  List<Thread> threadsNew = [];

  for (var thread in threads) {
    String? version = json['msg'][thread.id.toString()];
    if (version == null) {
      failed.add('${thread.name} (${thread.id})');
      continue;
    }
    threadsNew.add(thread.copyWith(currVersion: version));
  }

  await database.updateThreads(threadsNew);

  return UpdateResult(failed);
}
