class CRC16CCITT {
  /// محاسبه CRC16 با پلی‌نوم 0x1021 (CCITT)
  static List<int> appendCRC(List<int> data) {
    int crc = 0xFFFF;

    for (int byte in data) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }

    // اضافه کردن CRC به صورت Big Endian (بایت بالا اول)
    return [
      ...data,
      (crc >> 8) & 0xFF,
      crc & 0xFF,
    ];
  }

  /// تبدیل آرایه بایت به رشته Hex
  static String toHexString(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// تبدیل آرایه بایت به رشته Hex با فاصله
  static String bytesToHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }
}