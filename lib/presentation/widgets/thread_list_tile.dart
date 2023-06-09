import 'package:flutter/material.dart';

import '../../database/db.dart';
import 'thread_card_expanded.dart';

class ThreadListTile extends StatelessWidget {
  const ThreadListTile({super.key, required this.thread});

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
            side: thread.prevVersion != thread.currVersion
                ? const BorderSide(color: Colors.yellow, width: 2)
                : const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExpandedThreadCard(thread: thread);
            }));
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 450) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Version(thread: thread),
                    ],
                  );
                } else {
                  return Flexible(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Version(thread: thread),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ));
  }
}

class Version extends StatelessWidget {
  const Version({super.key, required this.thread});

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    if (thread.prevVersion == thread.currVersion) {
      return Text(
        thread.prevVersion,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          fontFamily: 'Mono',
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Mono',
          ),
          children: [
            TextSpan(
              text: thread.prevVersion,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            TextSpan(
              text: ' ${thread.currVersion}',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.yellow,
              ),
            ),
          ],
        ),
      );
    }
  }
}
