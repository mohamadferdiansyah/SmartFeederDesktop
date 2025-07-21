import 'package:flutter/material.dart';

class HalterStablePage extends StatefulWidget {
  const HalterStablePage({super.key});

  @override
  State<HalterStablePage> createState() => _HalterStablePageState();
}

class _HalterStablePageState extends State<HalterStablePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Stable Page'),
    );
  }
}
