import 'dart:async';
import 'package:flutter/material.dart';

class PressButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const PressButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  Timer? _longPressTimer;
  Timer? _repeatTimer;

  void _onTap() {
    widget.onTap.call();
  }



  @override
  void dispose() {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }



}