import 'package:flutter/material.dart';

class HalterSettingPage extends StatefulWidget {
  const HalterSettingPage({super.key});

  @override
  State<HalterSettingPage> createState() => _HalterSettingPageState();
}

class _HalterSettingPageState extends State<HalterSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Help Page'),
    );
  }
}
