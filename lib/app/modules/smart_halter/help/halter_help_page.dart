import 'package:flutter/material.dart';

class HalterHelpPage extends StatefulWidget {
  const HalterHelpPage({super.key});

  @override
  State<HalterHelpPage> createState() => _HalterHelpPageState();
}

class _HalterHelpPageState extends State<HalterHelpPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Help Page'),
    );
  }
}
