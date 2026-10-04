import 'package:flutter/material.dart';

import '../screens/assistant/ai_assistant_screen.dart';
import '../screens/farm/my_farm_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/more/more_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../widgets/bottom_navigation.dart';
import 'app_routes.dart';

/// Gives any descendant a way to switch the bottom-nav tab, e.g. the Home
/// "Scan My Crop" card jumping to the Scan tab.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.currentIndex,
    required this.goTo,
    required super.child,
  });

  final int currentIndex;
  final void Function(int index) goTo;

  static MainShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  static MainShellScope of(BuildContext context) => maybeOf(context)!;

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      currentIndex != oldWidget.currentIndex;
}

/// Persistent bottom navigation host for the five primary destinations.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = MainTab.home});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _goTo(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      currentIndex: _index,
      goTo: _goTo,
      child: PopScope(
        canPop: _index == MainTab.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goTo(MainTab.home);
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              ScanScreen(),
              AiAssistantScreen(),
              MyFarmScreen(),
              MoreScreen(),
            ],
          ),
          bottomNavigationBar: AppBottomNavigation(
            currentIndex: _index,
            onTap: _goTo,
          ),
        ),
      ),
    );
  }
}
