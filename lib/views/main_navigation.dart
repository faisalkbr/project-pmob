// ============================================
// FILE: lib/views/main_navigation.dart
// ============================================

import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'competition_screen/competition_screen.dart';
import 'dashboard_screen/dashboard_screen.dart';
import 'product_screen/product_screen.dart';
import 'profile_screen/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardScreen(),
    CompetitionScreen(),
    ProductScreen(),
    ProfileScreen(),
  ];

  void _switchTab(int index) {
    if (index < 0 || index >= _pages.length) return;
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationScope(
      switchTab: _switchTab,
      currentIndex: _currentIndex,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
        ),
      ),
    );
  }
}

/// InheritedWidget supaya screen anak bisa pindah tab tanpa lewat callback prop.
/// Pakai dari mana saja: `MainNavigationScope.of(context)?.switchTab(2)`.
class MainNavigationScope extends InheritedWidget {
  const MainNavigationScope({
    super.key,
    required this.switchTab,
    required this.currentIndex,
    required super.child,
  });

  final void Function(int index) switchTab;
  final int currentIndex;

  static MainNavigationScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavigationScope>();
  }

  @override
  bool updateShouldNotify(MainNavigationScope old) =>
      old.currentIndex != currentIndex;
}
