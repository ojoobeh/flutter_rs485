import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled4/core/extensions/widget_extension.dart';
import 'package:untitled4/models/serial_packet.dart';
import 'package:untitled4/screens/home/home_controller.dart';
import 'package:untitled4/screens/nega_scope_screen.dart';
import 'package:untitled4/services/crc16_service.dart';
import 'package:untitled4/services/serial_service.dart';
import 'package:untitled4/widgets/long_press_button.dart';
import 'package:untitled4/widgets/press_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomeController {
  @override
  void initState() {
    super.initState();

    onTimerTextChanged = () {
      if (mounted) {
        setState(() {});
      }
    };

    openSerialPort();
  }

  // ============ دستورات ============

  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: _body())),
    );
  }

  Widget _body() => Container(
    padding: EdgeInsets.all(32),
    child: Column(
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 16,
          children: [
            PressButton(onTap: setHitterCode, label: 'Hitter').expanded(),
            PressButton(
              label: 'NegaScope',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NegaScopeScreen())),
            ).expanded(),

            PressButton(onTap: setHitterCode, label: 'Hitter').expanded(),
            // LongPressButton(label: 'P1', onTap: setP1Code, onLongPress: setP1LongCode, longPressDuration: const Duration(seconds: 3)).expanded(),
            PressButton(onTap: () {}, label: 'A6').expanded(),
          ],
        ),


        Row(
          spacing: 16,
          children: [
            LongPressButton(
              label: 'Glass',
              onTap: () {},
              onUnderOneSecond: setGlassCode,
              onLongPressRepeat: onGlassRepeat,
              onLongPressEnd: onGlassLongPressEnd,
            ).expanded(),
//
            LongPressButton(
              label: 'Crashvar',
              onTap: () {},
              onUnderOneSecond: setCrashvarCode,
              onLongPressRepeat: onCrashvarRepeat,
              onLongPressEnd: onCrashvarLongPressEnd,
            ).expanded(),
          ],
        ),

        Text(
          timerText,
          textAlign: TextAlign.center,
        ),


      ],
    ),
  );




}
