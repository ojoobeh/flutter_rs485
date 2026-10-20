import 'package:untitled4/new/models/home_button_config.dart';
import 'package:untitled4/screens/nega_scope_screen.dart';

/// 📌 برای اضافه کردن دکمه جدید فقط به این لیست یک آیتم اضافه کنید
final List<HomeButtonConfig> homeButtons = [
  // Negatoskop - کد 0x07
  const HomeButtonConfig(
    label: 'Negatoskop',
    action: ButtonAction.rawCommand,
    payload: [0x01, 0x07, 0x00],
  ),

  // NegaScope - باز کردن صفحه
  HomeButtonConfig(
    label: 'NegaScope',
    action: ButtonAction.navigate,
    screenBuilder: (_) => const NegaScopeScreen(),
  ),

  // Hitter - کد 0x01
  const HomeButtonConfig(
    label: 'Hitter',
    action: ButtonAction.rawCommand,
    payload: [0x01, 0x01, 0x00],
  ),

  // P1 - کد 0x03 با long press => 0x11
  const HomeButtonConfig(
    label: 'P1',
    action: ButtonAction.rawCommand,
    payload: [0x01, 0x03, 0x00],
    longPressAction: ButtonAction.command,
    longPressPayload: 0x11,
    longPressDuration: Duration(seconds: 3),
  ),

  // ========== نمونه دکمه‌های جدید (فقط uncomment کنید) ==========

  // const HomeButtonConfig(
  //   label: 'Glass Start',
  //   action: ButtonAction.rawCommand,
  //   payload: [0x01, 0x17, 0x00],
  // ),
  //
  // const HomeButtonConfig(
  //   label: 'Crashvar Start',
  //   action: ButtonAction.rawCommand,
  //   payload: [0x01, 0x18, 0x00],
  // ),
];