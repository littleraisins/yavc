import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lehttp_overrides/lehttp_overrides.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'presentation/root.dart';

void main() async {
  // Adding new Let's Encrypt root certificate for old Android devices <7.1.1
  if (Platform.isAndroid) {
    HttpOverrides.global = LEHttpOverrides();
  }

  final appDir = await getApplicationSupportDirectory();
  final hivePath = path.join(appDir.path, 'hive').toString();
  await Hive.openBox('settings', path: hivePath);

  runApp(const ProviderScope(child: MyApp()));

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.alignment = Alignment.center;
      appWindow.maximize();
      appWindow.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'YAVC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Lato',
          brightness: Brightness.dark,
          colorSchemeSeed: const Color.fromARGB(255, 186, 49, 49),
        ),
        home: const RootNavigator(),
      ),
    );
  }
}
