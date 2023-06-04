import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yavc/presentation/state.dart';

import 'pages/home.dart';
import 'pages/settings.dart';

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

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
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
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
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
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
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
