import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../data_extraction/parsing.dart';
import '../../../../data_extraction/text_manipulation.dart';
import '../../../../database/db.dart';
import '../actions.dart';
import '../state.dart';
import 'settings_card.dart';

enum IEType { threads, database }

class ImportExportWidget extends ConsumerStatefulWidget {
  const ImportExportWidget({Key? key}) : super(key: key);
  @override
  ConsumerState<ImportExportWidget> createState() => _ImportExportWidgetState();
}

class _ImportExportWidgetState extends ConsumerState<ImportExportWidget> {
  IEType importExportType = IEType.database;
  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(loadingProvider);
    final importProgress = ref.watch(importProgressProvider);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!loading) ...[
            const Text('Import & Export', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            SegmentedButton<IEType>(
              segments: const [
                ButtonSegment<IEType>(
                  value: IEType.database,
                  label: Text('Database'),
                  icon: Icon(Icons.storage),
                ),
                ButtonSegment<IEType>(
                  value: IEType.threads,
                  label: Text('Threads'),
                  icon: Icon(Icons.list),
                ),
              ],
              selected: <IEType>{importExportType},
              onSelectionChanged: (Set<IEType> newSelection) {
                setState(() {
                  importExportType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 10),
            if (importExportType == IEType.threads) ...[
              const Text(
                'Please use database import if you can, this way you will avoid sending unnecessary requests to F95Zone servers',
                style: TextStyle(color: Colors.amber),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      switch (importExportType) {
                        case IEType.database:
                          importDatabase(context, ref);
                        case IEType.threads:
                          importThreads(context, ref);
                      }
                    },
                    label: const Text('Import'),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      switch (importExportType) {
                        case IEType.database:
                          exportDatabase(context);
                        case IEType.threads:
                          await exportThreads(context, ref);
                      }
                    },
                    label: const Text('Export'),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                )
              ],
            ),
          ] else ...[
            const Text('Thread import in progress',
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: importProgress,
            )
          ]
        ],
      ),
    );
  }
}

importThreads(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  await showDialog(
      context: context,
      builder: (c) => AlertDialog(
            title: const Text('Import'),
            content: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Paste links here, one link per line',
              ),
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            actions: [
              TextButton(
                child: const Text('Start import'),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                  if (controller.text.trim().isNotEmpty) {
                    await _import(context, ref, controller.text.split('\n'))
                        .then((result) {
                      String errortext = '';
                      if (result.exists.isNotEmpty) {
                        errortext += '\n\nSkipped duplicates:';
                        for (var link in result.exists) {
                          errortext += '\n$link';
                        }
                      }
                      if (result.failedToRecognize.isNotEmpty) {
                        errortext += '\n\nFailed to recognize links:';
                        for (var link in result.failedToRecognize) {
                          errortext += '\n$link';
                        }
                      }
                      if (result.failedToParse.isNotEmpty) {
                        errortext += '\n\nFailed to parse links:';
                        for (var link in result.failedToParse) {
                          errortext += '\n$link';
                        }
                      }
                      alert(
                        context,
                        title: 'Import',
                        content: 'Import finished$errortext',
                      );
                    });
                  }
                },
              ),
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ));
}

class ImportResult {
  List<String> exists;
  List<String> failedToParse;
  List<String> failedToRecognize;
  ImportResult(this.exists, this.failedToParse, this.failedToRecognize);
}

Future<ImportResult> _import(
  BuildContext context,
  WidgetRef ref,
  List<String> links,
) async {
  ref.read(loadingProvider.notifier).state = true;
  final database = ref.read(AppDatabase.provider);
  List<int> ids = [];
  List<String> exists = [];
  List<String> failedToParse = [];
  List<String> failedToRecognize = [];
  for (String link in links) {
    int? id = extractIdFromRawInput(link);
    if (id == null) {
      failedToRecognize.add(link);
    } else {
      ids.add(id);
    }
  }
  double counter = 0.0;
  for (int id in ids) {
    try {
      if (await database.threadExists(id)) {
        exists.add('https://f95zone.to/threads/$id');
        continue;
      }
      var result = await compute(parseThread, id);
      await database.threads.insertOne(ThreadsCompanion.insert(
        id: Value(id),
        name: result.name,
        labels: result.labels,
        developer: result.developer,
        prevVersion: result.version,
        currVersion: result.version,
        banner: result.banner,
        tags: Value(result.tags),
        description: Value(result.description),
        lastUpdated: Value(result.lastUpdated),
      ));
      counter += 1.0;
      ref.read(importProgressProvider.notifier).state = counter / ids.length;
    } catch (_) {
      failedToParse.add('https://f95zone.to/threads/$id');
    } finally {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  ref.read(loadingProvider.notifier).state = false;
  ref.read(importProgressProvider.notifier).state = 0.0;

  return ImportResult(exists, failedToParse, failedToRecognize);
}

exportThreads(BuildContext context, WidgetRef ref) async {
  final database = ref.read(AppDatabase.provider);
  await database.threads.all().get().then((threads) {
    List<String> urls =
        threads.map((t) => 'https://f95zone.to/threads/${t.id}').toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export'),
        content: threads.isEmpty
            ? const Text('No threads')
            : SelectableText(urls.join('\n')),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  });
}

importDatabase(BuildContext context, WidgetRef ref) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    String? newDbPath = result.files.single.path;
    if (newDbPath != null) {
      final appDir = await getApplicationSupportDirectory();
      // backup old file
      final dbFile = File(path.join(appDir.path, 'yavc.db'));
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await dbFile.copy(path.join(appDir.path, '$timestamp.bak'));
      // copy new file
      final newDbFile = File(newDbPath);
      await newDbFile.copy(path.join(appDir.path, 'yavc.db.new')).then((_) {
        alert(context,
                title: 'Import',
                content:
                    'Database import finished\nPlease RESTART THE APP to use new database')
            .then((_) {});
      });
    }
  }
}

exportDatabase(BuildContext context) async {
  if (Platform.isAndroid) {
    await Permission.storage.request().then((status) {
      if (status.isDenied) {
        alert(
          context,
          title: 'Error',
          content: 'To perform this action please allow file access',
        );
        return;
      }
    });
  }
  String? destDir = await FilePicker.platform.getDirectoryPath();
  if (destDir != null) {
    final appDir = await getApplicationSupportDirectory();
    final dbFile = File(path.join(appDir.path, 'yavc.db'));
    await dbFile.copy(path.join(destDir, 'yavc.db')).then((_) {
      alert(context,
          title: 'Export',
          content:
              'Database export finished\nLocation: "${path.join(destDir, 'yavc.db')}"');
    });
  }
}
