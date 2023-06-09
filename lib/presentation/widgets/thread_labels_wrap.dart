import 'package:flutter/material.dart';

import '../../database/db.dart';
import '../label_colors.dart';

class ThreadLabelsWrap extends StatelessWidget {
  const ThreadLabelsWrap({
    super.key,
    required this.thread,
  });

  final Thread thread;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var label in thread.labels)
          DecoratedBox(
            decoration: BoxDecoration(
                color: getLabelBackgroundColor(label),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: getLabelForegroundColor(label),
                ),
              ),
            ),
          )
      ],
    );
  }
}
