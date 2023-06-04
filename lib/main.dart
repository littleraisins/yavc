import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lehttp_overrides/lehttp_overrides.dart';
import 'package:window_manager/window_manager.dart';

import 'presentation/root.dart';

void main() async {
  // Adding new Let's Encrypt root certificate for old Android devices <7.1.1
  // See: https://pub.dev/packages/lehttp_overrides
  if (Platform.isAndroid) {
    HttpOverrides.global = LEHttpOverrides();
  }
  // Desktop window setup
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(center: true);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  // Run
  runApp(const ProviderScope(child: MyApp()));
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
