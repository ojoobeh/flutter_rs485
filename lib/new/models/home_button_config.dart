import 'package:flutter/material.dart';

/// نوع اکشن دکمه
enum ButtonAction {
  /// ارسال دستور با کد
  command,

  /// ارسال دستور خام (3 بایت)
  rawCommand,

  /// باز کردن صفحه جدید
  navigate,
}

/// پیکربندی هر دکمه در صفحه اصلی
class HomeButtonConfig {
  final String label;
  final ButtonAction action;

  /// برای action == command: کد دستور (مثلاً 0x01)
  /// برای action == rawCommand: 3 بایت
  final dynamic payload;

  /// برای long press
  final ButtonAction? longPressAction;
  final dynamic longPressPayload;
  final Duration longPressDuration;

  /// برای action == navigate
  final WidgetBuilder? screenBuilder;

  const HomeButtonConfig({
    required this.label,
    required this.action,
    this.payload,
    this.longPressAction,
    this.longPressPayload,
    this.longPressDuration = const Duration(seconds: 3),
    this.screenBuilder,
  });
}