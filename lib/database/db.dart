import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

import 'connection/connection.dart' as impl;

// generated using build script
part 'db.g.dart';

class Threads extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get labels => text().map(const ListConverter())();
  TextColumn get developer => text()();
  TextColumn get prevVersion => text()();
  TextColumn get currVersion => text()();
  BlobColumn get banner => blob()();
  TextColumn get tags =>
      text().map(const ListConverter()).withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get lastUpdated => text().withDefault(const Constant(''))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get lastFullRefresh => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ListConverter extends TypeConverter<List<String>, String> {
  const ListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.isNotEmpty ? fromDb.split(',') : [];
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

@DriftDatabase(tables: [Threads])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: ((m, from, to) async {
        await customStatement('PRAGMA foreign_keys = OFF');
        for (var step = from + 1; step <= to; step++) {
          switch (step) {
            case 2:
              await transaction(() async {
                await m.addColumn(threads, threads.tags);
                await m.addColumn(threads, threads.description);
                await m.addColumn(threads, threads.lastUpdated);
                await m.addColumn(threads, threads.archived);
                await m.addColumn(threads, threads.lastFullRefresh);
              });
              break;
          }
        }
      }),
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await impl.validateDatabaseSchema(this);
      },
    );
  }

  Stream<List<Thread>> activeThreads(String s) {
    return (select(threads)
          ..where((t) => t.name.contains(s) & t.archived.not())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.currVersion.equalsExp(t.prevVersion))
          ]))
        .watch();
  }

  Stream<List<Thread>> archivedThreads(String s) {
    return (select(threads)
          ..where((t) => t.name.contains(s) & t.archived.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  MultiSelectable<Thread> newThreads() {
    return (select(threads)
      ..where((t) => t.currVersion.isNotExp(t.prevVersion)));
  }

  Future<bool> threadExists(int id) async {
    List<Thread> result =
        await (select(threads)..where((t) => t.id.equals(id))).get();
    return result.isEmpty ? false : true;
  }

  Future deleteThread(int id) async {
    return (delete(threads)..where((t) => t.id.equals(id))).go();
  }

  Future resetThreadVersion(int id) async {
    Thread thread =
        await (select(threads)..where((t) => t.id.equals(id))).getSingle();
    String currVersion = thread.currVersion;
    return (update(threads)..where((t) => t.id.equals(id)))
        .write(ThreadsCompanion(prevVersion: Value(currVersion)));
  }

  Future updateCurrVersion(int id, String version) {
    return (update(threads)..where((tbl) => tbl.id.equals(id)))
        .write(ThreadsCompanion(currVersion: Value(version)));
  }

  Future updateThreads(List<Thread> threadList) {
    return transaction(() async {
      for (var thread in threadList) {
        await update(threads).replace(thread);
      }
    });
  }

  static final StateProvider<AppDatabase> provider = StateProvider((ref) {
    final database = AppDatabase();
    ref.onDispose(database.close);
    return database;
  });
}
