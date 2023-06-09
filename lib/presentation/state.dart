import 'package:riverpod/riverpod.dart';

import '../database/db.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

final importProgressProvider = StateProvider<double>((ref) => 0.0);

final refreshProgressProvider = StateProvider<double>((ref) => 0.0);

final searchQueryThreads = StateProvider<String>((ref) => '');
final allThreadsStreamProvider = StreamProvider<List<Thread>>((ref) {
  final database = ref.watch(AppDatabase.provider);
  final s = ref.watch(searchQueryThreads);
  return database.activeThreads(s);
});

final searchQueryArchive = StateProvider<String>((ref) => '');
final archivedThreadsStreamProvider = StreamProvider<List<Thread>>((ref) {
  final database = ref.watch(AppDatabase.provider);
  final s = ref.watch(searchQueryArchive);
  return database.archivedThreads(s);
});
