import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String routePath = '/dashboard';
  static const String routeName = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Weight Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _SummaryCard(title: 'Today\'s Weight', value: '-- kg'),
          SizedBox(height: 12),
          _SummaryCard(title: 'Trend', value: 'No data yet'),
          SizedBox(height: 12),
          _SummaryCard(title: 'Goal Progress', value: 'Set a goal to begin'),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
