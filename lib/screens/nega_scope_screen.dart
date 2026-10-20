import 'package:flutter/material.dart';

class NegaScopeScreen extends StatelessWidget {
  const NegaScopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NegaScope'),
      ),
      body: const Center(
        child: Text('NegaScope Screen'),
      ),
    );
  }
}