import 'package:riverpod/riverpod.dart';

import '../database/db.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

final importProgressProvider = StateProvider<double>((ref) => 0.0);

final searchQuery = StateProvider<String>((ref) => '');

final allThreadsStreamProvider = StreamProvider<List<Thread>>((ref) {
  final database = ref.watch(AppDatabase.provider);
  final s = ref.watch(searchQuery);
  return database.allThreads(s);
});
