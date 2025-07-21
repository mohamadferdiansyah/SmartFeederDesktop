import 'package:flutter/material.dart';

class HalterFeedPage extends StatefulWidget {
  const HalterFeedPage({super.key});

  @override
  State<HalterFeedPage> createState() => _HalterFeedPageState();
}

class _HalterFeedPageState extends State<HalterFeedPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text('Feed Page'),
    );
  }
}
