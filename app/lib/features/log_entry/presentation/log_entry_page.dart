import 'package:flutter/material.dart';

class LogEntryPage extends StatelessWidget {
  const LogEntryPage({super.key});

  static const String routePath = '/log';
  static const String routeName = 'log-entry';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Weight')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text('This screen will host the log weight form.'),
            SizedBox(height: 16),
            Text('Inputs for weight, date, notes, and actions will go here.'),
          ],
        ),
      ),
    );
  }
}
