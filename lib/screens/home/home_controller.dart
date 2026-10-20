import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled4/models/serial_packet.dart';
import 'package:untitled4/services/crc16_service.dart';
import 'package:untitled4/services/serial_service.dart';

mixin HomeController {
  final SerialService _serialService = SerialService();
  StreamSubscription? _dataSubscription;

  final PacketBuffer _packetBuffer = PacketBuffer();
  Timer? _timeoutTimer;

  List<int> _baseByte = List.from(SerialPacket.BASE_PACKET);
  final List<int> _baseByte4 = List.from(SerialPacket.BASE_PACKET);
  bool _isRefreshByte = true;
  bool _isReading = false;



  VoidCallback? onTimerTextChanged;

  String _timerText = '';

  String get timerText => _timerText;

  void _updateTimerText(String text) {
    _timerText = text;
    onTimerTextChanged?.call();
  }




  Future<void> openSerialPort() async {
    final success = await _serialService.open(port: '/dev/ttyS8', baudRate: 57600);

    if (success) {
      _appendText('Serial port opened at 57600 baud');
      _startReading();
    } else {
      _showToast('Error opening serial port');
    }
  }

  void _startReading() {
    _isReading = true;

    _dataSubscription = _serialService.dataStream.listen((data) {
      for (int byte in data) {
        final packet = _packetBuffer.addByte(byte);
        if (packet != null) {
          _processPacket(packet);
        }
      }
    });

    // تایمر برای بررسی timeout
    _timeoutTimer = Timer.periodic(const Duration(milliseconds: 1), (_) => _packetBuffer.checkTimeout());
  }

  void _processPacket(List<int> data) {
    final hex = CRC16CCITT.bytesToHex(data);
    _appendText('Received: $hex');

    // بررسی الگوی خاص
    if (SerialPacket.matchesPattern(data, SerialPacket.PATTERN)) {
      _sendData(_baseByte);
    }
  }

  Future<void> _sendData(List<int> data) async {
    await _serialService.write(data);

    if (_isRefreshByte) {
      _baseByte = List.from(_baseByte4);
    }
  }

  void _setCommand(int command) {
    if (!_isAccess()) {
      _showToast('خطا در ارسال اطلاعات به دستگاه 403');
      return;
    }

    final commandBytes = [0x01, command, 0x00];
    _baseByte = CRC16CCITT.appendCRC(commandBytes);
    _isRefreshByte = true;
  }

  void disposeAll() {
    _isReading = false;
    _timeoutTimer?.cancel();
    _dataSubscription?.cancel();
    _serialService.dispose();

  }

  void _appendText(String text) {
    // در نسخه اصلی خالی بود - می‌توانید لاگ کنید
    debugPrint(text);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  bool _isAccess() {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ دستورات ============

  void setHitterCode() {
    if (_isAccess()) {
      final baseByte1 = [0x01, 0x01, 0x00];
      _baseByte = CRC16CCITT.appendCRC(baseByte1);
      _isRefreshByte = true;
    } else {
      _showToast('خطا در ارسال اطلاعات به دستگاه 403');
    }
  }

  void setP1Code() {
    if (_isAccess()) {
      final baseByte1 = [0x01, 0x03, 0x00];
      _baseByte = CRC16CCITT.appendCRC(baseByte1);
      _isRefreshByte = true;
    } else {
      _showToast('خطا در ارسال اطلاعات به دستگاه 403');
    }
  }

  void setP1LongCode() {
    _setCommand(0x11);
  }

  // String _timerText = '';
  //
  // String get timerText => _timerText;
  //
  // void _updateTimerText(String text) {
  //   _timerText = text;
  //   // برای نمایش در UI، بخش بعدی را هم اضافه کن.
  // }



  void setGlassCode() {
    _setCommand(0x17);
  }

  void setGlassStartLongPressCode() {
    _setCommand(0x17);
  }

  void setGlassLongCode(int time) {
    debugPrint('Glass total seconds: $time');

    // اینجا منطق نهایی نسخه Java را قرار بده.
    // اگر setGlassLongCode در Java بسته دارای زمان می‌فرستد،
    // باید همان قالب بسته و CRC را اینجا پیاده‌سازی کنیم.
  }

  void setCrashvarCode() {
    _setCommand(0x18);
  }

  void setCrashvarStartLongPressCode() {
    _setCommand(0x18);
  }

  void setSaveCrashvarCode(int time) {
    debugPrint('Crashvar total seconds: $time');

    // اینجا منطق نهایی ارسال زمان Crashvar را قرار بده.
  }

  void onGlassRepeat(int elapsedMillis) {
    setGlassStartLongPressCode();
    updateGlassTimer(elapsedMillis);
  }

  void onCrashvarRepeat(int elapsedMillis) {
    setCrashvarStartLongPressCode();
    updateCrashvarTimer(elapsedMillis);
  }

  void onGlassLongPressEnd(int elapsedMillis) {
    setGlassLongCode(elapsedMillis ~/ 1000);
    _updateTimerText('');
  }

  void onCrashvarLongPressEnd(int elapsedMillis) {
    setSaveCrashvarCode(elapsedMillis ~/ 1000);
    _updateTimerText('');
  }

  void updateGlassTimer(int elapsedMillis) {
    final seconds = elapsedMillis ~/ 1000;
    _updateTimerText(
      'زمان مورد نیاز برای پر شدن لیوان: $seconds ثانیه',
    );
  }

  void updateCrashvarTimer(int elapsedMillis) {
    final seconds = elapsedMillis ~/ 1000;
    _updateTimerText(
      'زمان مورد نیاز برای کرشوار: $seconds ثانیه',
    );
  }


}
