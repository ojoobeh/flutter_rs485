import 'dart:typed_data';

class SerialPacket {
  static const int PACKET_SIZE = 5;

  /// پکت پایه
  static final List<int> BASE_PACKET = [0x01, 0x00, 0x00, 0xEF, 0x63];

  /// الگوی دریافت
  static final List<int> PATTERN = [0xE5, 0xE5, 0x01, 0x87, 0x8F];

  /// بررسی تطابق الگو
  static bool matchesPattern(List<int> data, List<int> pattern) {
    if (data.length != pattern.length) return false;
    for (int i = 0; i < data.length; i++) {
      if (data[i] != pattern[i]) return false;
    }
    return true;
  }

  /// بافر برای جمع‌آوری بایت‌ها
  static List<int> createBuffer() => List.filled(PACKET_SIZE, 0);
}

/// کلاس برای مدیریت بافر و timeout
class PacketBuffer {
  final List<int> _buffer = List.filled(SerialPacket.PACKET_SIZE, 0);
  int _index = 0;
  DateTime _lastByteTime = DateTime.now();
  static const Duration TIMEOUT = Duration(milliseconds: 4);

  /// اضافه کردن بایت. اگر پکت کامل شد، آن را برمی‌گرداند
  List<int>? addByte(int byte) {
    _buffer[_index++] = byte;
    _lastByteTime = DateTime.now();

    if (_index == SerialPacket.PACKET_SIZE) {
      final packet = List<int>.from(_buffer);
      _index = 0;
      return packet;
    }
    return null;
  }

  /// بررسی timeout
  void checkTimeout() {
    if (_index > 0 &&
        DateTime.now().difference(_lastByteTime) > TIMEOUT) {
      _index = 0;
    }
  }

  void reset() {
    _index = 0;
  }
}