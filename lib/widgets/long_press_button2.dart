import 'dart:async';
import 'package:flutter/material.dart';

class LongPressButton2 extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Duration longPressDuration;
  final Duration? repeatInterval;
  final VoidCallback? onRepeat;

  const LongPressButton2({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.longPressDuration = const Duration(seconds: 3),
    this.repeatInterval,
    this.onRepeat,
  });

  @override
  State<LongPressButton2> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton2> {
  Timer? _longPressTimer;
  Timer? _repeatTimer;
  bool _isLongPressed = false;

  void _onTapDown(TapDownDetails details) {
    _isLongPressed = false;
    _longPressTimer = Timer(widget.longPressDuration, () {
      _isLongPressed = true;
      widget.onLongPress?.call();

      // شروع تکرار اگر تنظیم شده باشد
      if (widget.repeatInterval != null && widget.onRepeat != null) {
        _repeatTimer = Timer.periodic(widget.repeatInterval!, (_) {
          widget.onRepeat?.call();
        });
      }
    });
  }

  void _onTapUp(TapUpDetails details) {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();

    if (!_isLongPressed) {
      widget.onTap();
    }
  }

  void _onTapCancel() {
    _longPressTimer?.cancel();
    _repeatTimer?.cancel();
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
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}