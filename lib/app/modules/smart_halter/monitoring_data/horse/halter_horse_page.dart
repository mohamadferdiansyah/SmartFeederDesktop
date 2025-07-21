import 'package:flutter/material.dart';

class HalterHorsePage extends StatefulWidget {
  const HalterHorsePage({super.key});

  @override
  State<HalterHorsePage> createState() => _HalterHorsePageState();
}

class _HalterHorsePageState extends State<HalterHorsePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Horse Page'),
    );
  }
}
