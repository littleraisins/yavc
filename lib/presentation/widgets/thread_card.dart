import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../database/db.dart';
import 'thread_card_expanded.dart';
import 'thread_labels_wrap.dart';

class ThreadCard extends StatelessWidget {
  const ThreadCard({super.key, required this.thread});

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 5,
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExpandedThreadCard(thread: thread);
            }));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.memory(thread.banner).image,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (thread.prevVersion != thread.currVersion) ...[
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        thread.currVersion,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Lottie.asset(
                    'assets/lottie-new.json',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    animate: true,
                    repeat: true,
                  ),
                ]
              ]),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThreadLabelsWrap(thread: thread),
                      Text(
                        thread.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        thread.prevVersion,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Mono',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ));
  }
}
