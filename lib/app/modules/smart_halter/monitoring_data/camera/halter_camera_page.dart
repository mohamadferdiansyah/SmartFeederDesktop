import 'package:flutter/material.dart';

class HalterCameraPage extends StatefulWidget {
  const HalterCameraPage({super.key});

  @override
  State<HalterCameraPage> createState() => _HalterCameraPageState();
}

class _HalterCameraPageState extends State<HalterCameraPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Camera Page'),
    );
  }
}
