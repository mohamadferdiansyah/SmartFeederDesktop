import 'package:flutter/material.dart';

class WalkerDashboardPage extends StatefulWidget {
  const WalkerDashboardPage({super.key});

  @override
  State<WalkerDashboardPage> createState() => WalkerDashboardPageState();
}

class WalkerDashboardPageState extends State<WalkerDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Dashboard Page'),
    );
  }
}