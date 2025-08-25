import 'package:flutter/material.dart';

class MonitorDashboardPage extends StatefulWidget {
  const MonitorDashboardPage({super.key});

  @override
  State<MonitorDashboardPage> createState() => MonitorDashboardPageState();
}

class MonitorDashboardPageState extends State<MonitorDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Dashboard Page'),
    );
  }
}
