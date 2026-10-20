import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled4/models/serial_packet.dart';
import 'package:untitled4/services/crc16_service.dart';
import 'package:untitled4/services/serial_service.dart';

mixin SerialCommandMixin<T extends StatefulWidget> on State<T> {
  final SerialService _serialService = SerialService();
  StreamSubscription? _dataSubscription;
  final PacketBuffer _packetBuffer = PacketBuffer();
  Timer? _timeoutTimer;

  List<int> _baseByte = List.from(SerialPacket.BASE_PACKET);
  final List<int> _baseByte4 = List.from(SerialPacket.BASE_PACKET);
  bool _isRefreshByte = true;
  bool _isReading = false;

  // ============ Lifecycle ============

  void initSerial() {
    _openSerialPort();
  }

  void disposeSerial() {
    _isReading = false;
    _timeoutTimer?.cancel();
    _dataSubscription?.cancel();
    _serialService.dispose();
  }

  // ============ Serial Port ============

  Future<void> _openSerialPort() async {
    final success = await _serialService.open(
      port: '/dev/ttyS8',
      baudRate: 57600,
    );

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

    _timeoutTimer = Timer.periodic(
      const Duration(milliseconds: 1),
          (_) => _packetBuffer.checkTimeout(),
    );
  }

  void _processPacket(List<int> data) {
    final hex = CRC16CCITT.bytesToHex(data);
    _appendText('Received: $hex');

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

  // ============ Helpers ============

  void _appendText(String text) => debugPrint(text);

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  bool _isAccess() {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ Command API (public) ============

  /// دستور عمومی: [0x01, command, 0x00] + CRC
  void sendCommand(int command) {
    if (!_isAccess()) {
      _showToast('خطا در ارسال اطلاعات به دستگاه 403');
      return;
    }

    final commandBytes = [0x01, command, 0x00];
    _baseByte = CRC16CCITT.appendCRC(commandBytes);
    _isRefreshByte = true;
  }

  /// ارسال یک بسته دلخواه (3 بایت اول) — برای دستورات سفارشی
  void sendRawCommand(List<int> threeBytes) {
    if (!_isAccess()) {
      _showToast('خطا در ارسال اطلاعات به دستگاه 403');
      return;
    }

    _baseByte = CRC16CCITT.appendCRC(threeBytes);
    _isRefreshByte = true;
  }
}