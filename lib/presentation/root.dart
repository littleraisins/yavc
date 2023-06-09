import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/archive.dart';
import 'pages/home.dart';
import 'pages/settings.dart';
import 'state.dart';

class RootNavigator extends ConsumerStatefulWidget {
  const RootNavigator({super.key});

  @override
  ConsumerState<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends ConsumerState<RootNavigator> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(loadingProvider);
    final newThreads = ref.watch(newThreadsProvider);
    final newThreadsAmount = newThreads.value?.length ?? 0;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const ArchivePage();
        break;
      case 2:
        page = const SettingsPage();
        break;
      default:
        throw UnimplementedError('No widget for nav index: $selectedIndex');
    }

    ColoredBox mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            children: [
              Expanded(child: mainArea),
              NavigationBar(
                elevation: 5,
                destinations: [
                  NavigationDestination(
                    icon: badges.Badge(
                      showBadge: newThreadsAmount > 0,
                      badgeContent: Text(
                        newThreadsAmount.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Colors.yellow,
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      child: const Icon(Icons.collections_bookmark),
                    ),
                    label: 'Collection',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.inventory),
                    label: 'Archive',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: loading
                    ? null
                    : (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
              )
            ],
          );
        } else {
          return Row(
            children: [
              NavigationRail(
                destinations: [
                  NavigationRailDestination(
                    icon: badges.Badge(
                      showBadge: newThreadsAmount > 0,
                      badgeContent: Text(
                        newThreadsAmount.toString(),
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Colors.yellow,
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      child: const Icon(Icons.collections_bookmark),
                    ),
                    label: const Text('Collection'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.inventory),
                    label: Text('Archive'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: loading
                    ? null
                    : (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: mainArea),
            ],
          );
        }
      },
    );
  }
}
