import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state.dart';

class MixedLoadingIndicator extends ConsumerWidget {
  const MixedLoadingIndicator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshProgress = ref.watch(refreshProgressProvider);
    return CircularProgressIndicator(
      strokeWidth: 3,
      value: refreshProgress > 0.0 ? refreshProgress : null,
    );
  }
}
