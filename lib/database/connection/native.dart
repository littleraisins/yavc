import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File> get databaseFile async {
  final appDir = await getApplicationSupportDirectory();
  final dbPath = path.join(appDir.path, 'yavc.db');
  final newDbPath = File(path.join(appDir.path, 'yavc.db.new'));
  final resetFile = File(path.join(appDir.path, 'reset'));
  if (await newDbPath.exists()) {
    await newDbPath.copy(dbPath).then((_) => newDbPath.delete());
  } else if (await resetFile.exists()) {
    await resetFile.delete();
    await File(dbPath).delete();
  }
  return File(dbPath);
}

DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future(() async {
    return NativeDatabase.createBackgroundConnection(await databaseFile);
  }));
}

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  if (kDebugMode) {
    await VerifySelf(database).validateDatabaseSchema();
  }
}
