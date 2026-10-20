import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class SerialService {
  static const MethodChannel _channel =
  MethodChannel('com.example.untitled4/serial');
  static const EventChannel _eventChannel =
  EventChannel('com.example.untitled4/serial_data');

  StreamSubscription? _dataSubscription;
  final _dataController = StreamController<List<int>>.broadcast();
  bool _isOpen = false;

  Stream<List<int>> get dataStream => _dataController.stream;
  bool get isOpen => _isOpen;

  /// باز کردن پورت سریال
  Future<bool> open({
    String port = '/dev/ttyS8',
    int baudRate = 57600,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('open', {
        'port': port,
        'baudRate': baudRate,
      });

      if (result == true) {
        _isOpen = true;
        _startListening();
        return true;
      }
      return false;
    } catch (e) {
      print('Error opening serial port: $e');
      return false;
    }
  }

  /// شروع گوش دادن به داده‌ها
  void _startListening() {
    _dataSubscription?.cancel();
    _dataSubscription = _eventChannel
        .receiveBroadcastStream()
        .listen(
          (data) {
        if (data is Uint8List) {
          _dataController.add(data.toList());
        } else if (data is List<int>) {
          _dataController.add(data);
        }
      },
      onError: (error) {
        print('Serial data error: $error');
      },
    );
  }

  /// ارسال داده
  Future<bool> write(List<int> data) async {
    if (!_isOpen) return false;

    try {
      final result = await _channel.invokeMethod<bool>('write', {
        'data': data,
      });
      return result ?? false;
    } catch (e) {
      print('Error writing to serial: $e');
      return false;
    }
  }

  /// بستن پورت
  Future<void> close() async {
    _dataSubscription?.cancel();
    _dataSubscription = null;

    if (_isOpen) {
      try {
        await _channel.invokeMethod('close');
      } catch (e) {
        print('Error closing serial: $e');
      }
      _isOpen = false;
    }
  }

  void dispose() {
    close();
    _dataController.close();
  }
}