import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../state.dart';
import '../widgets/thread_card.dart';
import '../widgets/thread_list_tile.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);
  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  final mainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mainController.text = ref.read(searchQueryArchive);
  }

  @override
  void dispose() {
    mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threads = ref.watch(archivedThreadsStreamProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(builder: (context, constraints) {
        final gridColumnCount = (constraints.maxWidth / 500).ceil();
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              TextField(
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: 'Search archive',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    suffixIcon: mainController.text.isEmpty
                        ? null
                        : IconButton(
                            splashRadius: 15,
                            onPressed: () {
                              mainController.clear();
                              ref.read(searchQueryArchive.notifier).state = '';
                            },
                            icon: const Icon(Icons.clear))),
                controller: mainController,
                onChanged: (text) {
                  ref.read(searchQueryArchive.notifier).state = text;
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: threads.when(
                    data: (threads) {
                      if (threads.isEmpty) {
                        if (mainController.text.isNotEmpty) {
                          return const Text('No matching threads...');
                        }
                        return const Center(
                            child: Text('No threads in archive'));
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
                                    return ThreadCard(thread: threads[index]);
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
                      return const Text('Error');
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
