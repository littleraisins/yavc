import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/db.dart';
import '../presentation/actions.dart';
import 'prefix_colors.dart';

class ExpandedThreadCard extends ConsumerWidget {
  const ExpandedThreadCard({super.key, required this.thread});

  final Thread thread;

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
                  Banner(thread: thread),
                  const SizedBox(height: 20),
                  TitleCard(thread: thread),
                  const SizedBox(height: 20),
                  LabelsAndTagsCard(thread: thread),
                  const SizedBox(height: 20),
                  VersionCard(thread: thread),
                  const SizedBox(height: 20),
                  ActionButtons(thread: thread),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VersionCard extends StatelessWidget {
  const VersionCard({
    super.key,
    required this.thread,
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  if (thread.prevVersion != thread.currVersion) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                                  decoration: TextDecoration.lineThrough,
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
                    Wrap(
                      children: [
                        Text(
                          thread.prevVersion,
                          style: const TextStyle(
                            fontFamily: 'Mono',
                          ),
                        ),
                        if (thread.lastUpdated.isNotEmpty)
                          Text(
                            ' (last update: ${thread.lastUpdated})',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Mono',
                            ),
                          ),
                      ],
                    ),
                  ],
                ]),
          ),
        ));
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
    required this.thread,
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Text(
                    thread.name,
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'by ${thread.developer}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ]),
          ),
        ));
  }
}

class LabelsAndTagsCard extends StatelessWidget {
  const LabelsAndTagsCard({
    super.key,
    required this.thread,
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            Wrap(
              spacing: 4,
              runSpacing: 6,
              children: [
                for (var label in thread.labels)
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: getLabelBackgroundColor(label),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: getLabelForegroundColor(label),
                        ),
                      ),
                    ),
                  ),
                for (var tag in thread.tags)
                  DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Color(0xFF37383A),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 1),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF9398A0),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class Banner extends StatelessWidget {
  const Banner({
    super.key,
    required this.thread,
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      speed: 300,
      fill: Fill.fillBack,
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
      front: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.memory(thread.banner).image,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
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
      back: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                thread.description,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButtons extends ConsumerWidget {
  const ActionButtons({
    super.key,
    required this.thread,
  });

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

  void _toggleArchive(BuildContext context, WidgetRef ref) async {
    var text = thread.archived
        ? 'This thread will be removed from archive'
        : 'This thread will be moved to archive';
    if (await confirm(context, content: text)) {
      final database = ref.read(AppDatabase.provider);
      await database.updateThreads(
          [thread.copyWith(archived: !thread.archived)]).then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 450) {
        return Column(
          children: [
            if (thread.prevVersion != thread.currVersion)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => _resetVersion(context, ref),
                icon: const Icon(Icons.done),
                label: const Text('Reset version'),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: _openThread,
              icon: const Icon(Icons.launch),
              label: const Text('Thread'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => _toggleArchive(context, ref),
              icon: thread.archived
                  ? const Icon(Icons.unarchive)
                  : const Icon(Icons.archive),
              label: thread.archived
                  ? const Text('Activate')
                  : const Text('Archive'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
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
                onPressed: () => _toggleArchive(context, ref),
                icon: thread.archived
                    ? const Icon(Icons.unarchive)
                    : const Icon(Icons.archive),
                label: thread.archived
                    ? const Text('Activate')
                    : const Text('Archive'),
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
    });
  }
}
