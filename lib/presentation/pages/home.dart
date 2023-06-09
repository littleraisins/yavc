import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:yavc/presentation/widgets/thread_list_tile.dart';

import '../../data_extraction/parsing.dart';
import '../../data_extraction/text_manipulation.dart';
import '../../database/db.dart';
import '../actions.dart';
import '../state.dart';
import '../widgets/mixed_loading_indicator.dart';
import '../widgets/thread_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final mainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mainController.text = ref.read(searchQueryThreads);
  }

  @override
  void dispose() {
    mainController.dispose();
    super.dispose();
  }

  void _showErrorInSnack(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _addThread() async {
    if (mainController.text.isNotEmpty) {
      ref.read(loadingProvider.notifier).state = true;

      String rawInput = mainController.text;
      int? id = extractIdFromRawInput(rawInput);

      if (id == null) {
        _showErrorInSnack(
            'Failed to parse your input.\nPlease provide thread id or full link.');
        ref.read(loadingProvider.notifier).state = false;
        return;
      }

      final database = ref.read(AppDatabase.provider);

      if (await database.threadExists(id)) {
        _showErrorInSnack('Thread already added');
      } else {
        try {
          ParsingResult result = await compute(parseThread, id);
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
            lastFullRefresh: Value(DateTime.now().millisecondsSinceEpoch),
          ));
        } catch (e) {
          _showErrorInSnack(e.toString());
        }
      }
    }

    ref.read(loadingProvider.notifier).state = false;
    ref.read(searchQueryThreads.notifier).state = '';
    mainController.clear();
  }

  void _refresh() async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      await refresh(ref).then((UpdateResult result) {
        if (result.failed.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning'),
                content: Text(
                    "Failed to update some threads:\n\n${result.failed.join('\n')}"),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Dismiss'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {
      _showErrorInSnack(e.toString());
    }
    ref.read(loadingProvider.notifier).state = false;
  }

  void _tryToRestoreBackup() async {
    await _restore().then((_) {
      alert(context,
          title: 'Restore',
          content:
              'Backup restore finished\nPlease RESTART THE APP to see results');
    });
  }

  Future<void> _restore() async {
    final appDir = await getApplicationSupportDirectory();
    List<FileSystemEntity> files = await appDir.list().toList();
    List<String> backupFiles = [];
    for (var file in files) {
      var filename = file.uri.pathSegments.last;
      if (filename.endsWith('.bak')) backupFiles.add(filename);
    }
    if (backupFiles.isEmpty) {
      final resetFile = File(path.join(appDir.path, 'reset'));
      await resetFile.create();
      return;
    }
    List<int> timestamps = backupFiles
        .map((f) => int.parse(f.toString().split('.').first))
        .toList();
    timestamps.sort();
    final dbBakFile = File(path.join(appDir.path, '${timestamps.last}.bak'));
    await dbBakFile
        .copy(path.join(appDir.path, 'yavc.db.new'))
        .then((_) => dbBakFile.delete());
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(allThreadsStreamProvider);
    final loading = ref.watch(loadingProvider);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: showFab
          ? AbsorbPointer(
              absorbing: loading,
              child: FloatingActionButton(
                onPressed: _refresh,
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: MixedLoadingIndicator(),
                      )
                    : const Icon(Icons.refresh),
              ),
            )
          : null,
      body: LayoutBuilder(builder: (context, constraints) {
        final gridColumnCount = (constraints.maxWidth / 500).ceil();
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              AbsorbPointer(
                absorbing: loading,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Search or add new threads',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            suffixIcon: mainController.text.isEmpty
                                ? null
                                : IconButton(
                                    splashRadius: 15,
                                    onPressed: () {
                                      mainController.clear();
                                      ref
                                          .read(searchQueryThreads.notifier)
                                          .state = '';
                                    },
                                    icon: const Icon(Icons.clear))),
                        controller: mainController,
                        onSubmitted: (_) => _addThread(),
                        onChanged: (text) {
                          ref.read(searchQueryThreads.notifier).state = text;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      child: IconButton.filledTonal(
                        onPressed:
                            mainController.text.isEmpty ? null : _addThread,
                        icon: loading
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: MixedLoadingIndicator())
                            : const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: threads.when(
                    data: (threads) {
                      if (threads.isEmpty) {
                        if (mainController.text.isNotEmpty) {
                          return const Text('No matching threads...');
                        }
                        return const Center(child: Text('Database empty'));
                      } else {
                        return ValueListenableBuilder<Box>(
                            valueListenable: Hive.box('settings').listenable(),
                            builder: (context, box, widget) {
                              String selectedLayout =
                                  box.get('layout') ?? 'grid';
                              if (selectedLayout == 'grid') {
                                return DynamicHeightGridView(
                                  itemCount: threads.length,
                                  crossAxisCount: gridColumnCount,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                  builder: (context, index) {
                                    return AbsorbPointer(
                                      absorbing: loading,
                                      child: ThreadCard(thread: threads[index]),
                                    );
                                  },
                                );
                              } else if (selectedLayout == 'list') {
                                return ListView.separated(
                                    itemCount: threads.length,
                                    itemBuilder: (context, i) {
                                      return ThreadListTile(thread: threads[i]);
                                    },
                                    separatorBuilder: (context, i) {
                                      return const SizedBox(height: 10);
                                    });
                              } else {
                                return const Text('Invalid layout selected');
                              }
                            });
                      }
                    },
                    error: (e, s) {
                      debugPrintStack(label: e.toString(), stackTrace: s);
                      return Column(
                        children: [
                          const Text('An error has occured.'),
                          const Text('Your database might be corrupted.'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: _tryToRestoreBackup,
                              child: const Text(
                                  'Try to restore from latest backup')),
                        ],
                      );
                    },
                    loading: () => const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        )),
              ),
            ]),
          ),
        );
      }),
    );
  }
}
