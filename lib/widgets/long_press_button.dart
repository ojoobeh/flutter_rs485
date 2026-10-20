
import 'dart:async';

import 'package:flutter/material.dart';

class LongPressButton extends StatefulWidget {
  final String label;

  final VoidCallback onTap;
  final VoidCallback? onUnderOneSecond;
  final VoidCallback? onUnderThreeSeconds;
  final VoidCallback? onLongPress;

  final ValueChanged<int>? onPressDuration;
  final VoidCallback? onLongPressStart;

  // اجرای تکراری هنگام نگه داشتن دکمه
  final ValueChanged<int>? onLongPressRepeat;

  // زمان سپری‌شده در حلقه تکرار، برحسب میلی‌ثانیه
  final ValueChanged<int>? onLongPressEnd;

  const LongPressButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onUnderOneSecond,
    this.onUnderThreeSeconds,
    this.onLongPress,
    this.onLongPressStart,
    this.onPressDuration,
    this.onLongPressRepeat,
    this.onLongPressEnd,
  });

  @override
  State<LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  DateTime? _pressStartTime;

  Timer? _longPressTimer;
  Timer? _repeatTimer;

  bool _isLongPressStarted = false;
  int _elapsedMillis = 0;

  void _onPointerDown(TapDownDetails details) {
    _pressStartTime = DateTime.now();

    _isLongPressStarted = false;
    _elapsedMillis = 0;

    _longPressTimer?.cancel();
    _repeatTimer?.cancel();

    widget.onTap();

    // پس از یک ثانیه، عملیات نگه داشتن شروع می‌شود.
    _longPressTimer = Timer(
      const Duration(seconds: 1),
          () {
        if (!mounted || _pressStartTime == null) return;

        _isLongPressStarted = true;

        widget.onLongPressStart?.call();

        // مطابق جاوا: اجرای فوری Runnable
        _repeatLongPress();

        // سپس هر 500 میلی‌ثانیه
        _repeatTimer = Timer.periodic(
          const Duration(milliseconds: 500),
              (_) => _repeatLongPress(),
        );
      },
    );
  }

  void _repeatLongPress() {
    if (_pressStartTime == null) return;

    _elapsedMillis += 500;
    widget.onLongPressRepeat?.call(_elapsedMillis);

    // مقدار زمان در اختیار کنترلر قرار می‌گیرد.
    // نمایش متن زمان را کنترلر انجام می‌دهد.
  }

  void _onPointerUp(TapUpDetails details) {
    _handlePressEnd();
  }

  void _onPointerCancel() {
    _handlePressEnd();
  }

  void _handlePressEnd() {
    final startTime = _pressStartTime;
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    final milliseconds = duration.inMilliseconds;
    final wasLongPressStarted = _isLongPressStarted;
    final elapsedMillis = _elapsedMillis;

    _pressStartTime = null;
    _isLongPressStarted = false;

    _longPressTimer?.cancel();
    _longPressTimer = null;

    _repeatTimer?.cancel();
    _repeatTimer = null;

    widget.onPressDuration?.call(milliseconds);

    if (milliseconds < 1000) {
      widget.onUnderOneSecond?.call();
    } else {
      if (!wasLongPressStarted) {
        // حالت محافظتی برای جلوگیری از پایان بدون شروع
        widget.onLongPressStart?.call();
      }

      widget.onLongPress?.call();
      widget.onLongPressEnd?.call(elapsedMillis);
    }
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
      behavior: HitTestBehavior.opaque,
      onTapDown: _onPointerDown,
      onTapUp: _onPointerUp,
      onTapCancel: _onPointerCancel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
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
