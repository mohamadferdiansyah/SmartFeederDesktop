import 'package:flutter/material.dart';

class HalterDevicePage extends StatefulWidget {
  const HalterDevicePage({super.key});

  @override
  State<HalterDevicePage> createState() => _HalterDevicePageState();
}

class _HalterDevicePageState extends State<HalterDevicePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Device Page'),
    );
  }
}
