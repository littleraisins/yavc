import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'settings_card.dart';

enum Layouts { grid, list }

class LayoutChooseWidget extends ConsumerStatefulWidget {
  const LayoutChooseWidget({Key? key}) : super(key: key);
  @override
  ConsumerState createState() => _LayoutChooseWidgetState();
}

class _LayoutChooseWidgetState extends ConsumerState<LayoutChooseWidget> {
  Layouts layout = Layouts.grid;
  @override
  Widget build(BuildContext context) {
    setState(() {
      var hiveValue = Hive.box('settings').get('collection_layout') ?? 'grid';
      layout = hiveValue == 'grid' ? Layouts.grid : Layouts.list;
    });
    return SettingsCard(
      child: Row(
        children: [
          const Expanded(
              child: Text('Collection layout', style: TextStyle(fontSize: 20))),
          ValueListenableBuilder<Box>(
            valueListenable: Hive.box('settings').listenable(),
            builder: (context, box, widget) {
              return SegmentedButton<Layouts>(
                segments: const [
                  ButtonSegment<Layouts>(
                    value: Layouts.grid,
                    label: Text('Grid'),
                    icon: Icon(Icons.grid_view),
                  ),
                  ButtonSegment<Layouts>(
                    value: Layouts.list,
                    label: Text('List'),
                    icon: Icon(Icons.view_list),
                  ),
                ],
                selected: <Layouts>{layout},
                onSelectionChanged: (Set<Layouts> newSelection) {
                  setState(() {
                    layout = newSelection.first;
                    box.put('collection_layout', newSelection.first.name);
                  });
                },
              );
            },
          )
        ],
      ),
    );
  }
}
