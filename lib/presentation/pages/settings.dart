import 'package:flutter/material.dart';

import '../widgets/import_export.dart';
import '../widgets/layout_chooser.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  LayoutChooseWidget(),
                  ImportExportWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
