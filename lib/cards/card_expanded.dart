import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yavc/presentation/actions.dart';

import '../database/db.dart';
import 'prefix_colors.dart';

class ExpandedThreadCard extends ConsumerWidget {
  const ExpandedThreadCard({super.key, required this.thread});

  final Thread thread;

  void _deleteThread(BuildContext context, WidgetRef ref) async {
    var delete =
        await confirm(context, content: 'Thread will be permanently deleted');
    if (delete) {
      final database = ref.read(AppDatabase.provider);
      await database.deleteThread(thread.id).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void _resetVersion(BuildContext context, WidgetRef ref) async {
    var reset = await confirm(context,
        content: 'This thread will be reset to current version');
    if (reset) {
      final database = ref.read(AppDatabase.provider);
      await database.resetThreadVersion(thread.id).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void _openThread() async {
    await launchUrl(
      Uri.parse('https://f95zone.to/threads/${thread.id}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    label: const Text('Return'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16.0 / 9.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: Image.memory(thread.banner).image,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      ),
                      if (thread.prevVersion != thread.currVersion)
                        Positioned(
                          top: -25,
                          right: 0,
                          child: Lottie.asset(
                            'assets/lottie-new.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            animate: true,
                            repeat: true,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  for (var label in thread.labels)
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: getLabelBackgroundColor(label),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 1),
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            color:
                                                getLabelForegroundColor(label),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                thread.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'by ${thread.developer}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (thread.prevVersion != thread.currVersion) ...[
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Mono',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: thread.prevVersion,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ${thread.currVersion}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  thread.prevVersion,
                                  style: const TextStyle(
                                    fontFamily: 'Mono',
                                  ),
                                ),
                              ],
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth < 450) {
                      return Column(
                        children: [
                          if (thread.prevVersion != thread.currVersion)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50), // NEW
                              ),
                              onPressed: () => _resetVersion(context, ref),
                              icon: const Icon(Icons.done),
                              label: const Text('Reset version'),
                            ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: _openThread,
                            icon: const Icon(Icons.launch),
                            label: const Text('Thread'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: () => _deleteThread(context, ref),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          ),
                        ],
                      );
                    } else {
                      return Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (thread.prevVersion != thread.currVersion)
                              ElevatedButton.icon(
                                onPressed: () => _resetVersion(context, ref),
                                icon: const Icon(Icons.done),
                                label: const Text('Reset version'),
                              ),
                            ElevatedButton.icon(
                              onPressed: _openThread,
                              icon: const Icon(Icons.launch),
                              label: const Text('Thread'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _deleteThread(context, ref),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
