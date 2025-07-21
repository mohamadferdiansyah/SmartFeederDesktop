import 'package:flutter/material.dart';

class HalterDashboardPage extends StatefulWidget {
  const HalterDashboardPage({super.key});

  @override
  State<HalterDashboardPage> createState() => HalterDashboardPageState();
}

class HalterDashboardPageState extends State<HalterDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Dashboard Page'),
    );
  }
}