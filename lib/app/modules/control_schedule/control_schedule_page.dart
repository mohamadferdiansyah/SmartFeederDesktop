import 'package:flutter/material.dart';

class ControlSchedulePage extends StatefulWidget {
  const ControlSchedulePage({super.key});

  @override
  State<ControlSchedulePage> createState() => _ControlSchedulePageState();
}

class _ControlSchedulePageState extends State<ControlSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Control Schedule Page'),
    );
  }
}
