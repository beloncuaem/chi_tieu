import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home/home_screen.dart';
import 'camera/camera_screen.dart';
import 'statistics/statistics_screen.dart';
import 'budget/budget_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0; // Default to HomeScreen (Tổng quan)

  final List<Widget> _screens = const [
    HomeScreen(),
    CameraScreen(),
    StatisticsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt_rounded),
            label: 'Chụp',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ngân sách',
          ),
        ],
      ),
    );
  }
}
