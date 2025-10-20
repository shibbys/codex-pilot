import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_page.dart';
import '../../settings/presentation/settings_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const String routePath = '/history';
  static const String routeName = 'history';

  @override
  Widget build(BuildContext context) {
    // Current page is History, keep index fixed to 1.
    const int currentIndex = 1;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text('Weight history will appear here.'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(DashboardPage.routePath);
              break;
            case 1:
              context.go(HistoryPage.routePath);
              break;
            case 2:
              context.go(SettingsPage.routePath);
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
