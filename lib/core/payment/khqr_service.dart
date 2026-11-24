class KhqrService {
  static const String merchantId = 'kalipstudio@aclb';
  static const String merchantName = 'KALIP STUDIO ATELIER';
  static const String merchantCity = 'PHNOM PENH';
  static const String merchantCategoryCode = '5691'; // Clothing store
  static const String countryCode = 'KH';

  // Official Store Owner ABA Bank Details
  static const String abaQrAssetPath = 'assets/images/aba_khqr.jpg';
  static const String abaBankName = 'ABA BANK';
  static const String abaAccountName = 'SENGHOUR PRAK';
  static const String abaAccountUsd = '000 817 811';
  static const String abaAccountUsdRaw = '000817811';
  static const String abaAccountKhr = '014 042 356';
  static const String abaAccountKhrRaw = '014042356';

  /// Standard CRC-16 / CCITT-FALSE calculation (Polynomial 0x1021, Initial 0xFFFF)
  static String calculateCrc16(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      final byte = data.codeUnitAt(i);
      crc ^= (byte << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  /// Builds a standard EMVCo TLV (Tag-Length-Value) string
  static String _buildTlv(String tag, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$tag$len$value';
  }

  /// Generates a compliant Bakong KHQR EMVCo dynamic QR payload
  static String generateKhqrPayload({
    required String orderNumber,
    required double amountUsd,
    bool isKhr = false,
    double exchangeRate = 4100.0,
  }) {
    final buffer = StringBuffer();

    // Tag 00: Payload Format Indicator
    buffer.write(_buildTlv('00', '01'));

    // Tag 01: Point of Initiation Method (12 = Dynamic QR with amount)
    buffer.write(_buildTlv('01', '12'));

    // Tag 29: Merchant Account Information (Bakong Account)
    final merchantAccountInfo = StringBuffer();
    merchantAccountInfo.write(_buildTlv('00', merchantId));
    merchantAccountInfo.write(_buildTlv('01', '001889988'));
    merchantAccountInfo.write(_buildTlv('02', 'BAKONG'));
    buffer.write(_buildTlv('29', merchantAccountInfo.toString()));

    // Tag 52: Merchant Category Code
    buffer.write(_buildTlv('52', merchantCategoryCode));

    // Tag 53: Transaction Currency (840 = USD, 116 = KHR)
    final currencyCode = isKhr ? '116' : '840';
    buffer.write(_buildTlv('53', currencyCode));

    // Tag 54: Transaction Amount
    final formattedAmount = isKhr
        ? (amountUsd * exchangeRate).round().toString()
        : amountUsd.toStringAsFixed(2);
    buffer.write(_buildTlv('54', formattedAmount));

    // Tag 58: Country Code
    buffer.write(_buildTlv('58', countryCode));

    // Tag 59: Merchant Name
    buffer.write(_buildTlv('59', merchantName));

    // Tag 60: Merchant City
    buffer.write(_buildTlv('60', merchantCity));

    // Tag 62: Additional Data Field (Bill Number / Order Reference)
    final additionalData = StringBuffer();
    additionalData.write(_buildTlv('01', orderNumber));
    additionalData.write(_buildTlv('02', '+85592888999'));
    additionalData.write(_buildTlv('03', 'BKK1 FLAGSHIP'));
    buffer.write(_buildTlv('62', additionalData.toString()));

    // Tag 63: CRC Checksum prefix
    final dataWithoutCrc = '${buffer.toString()}6304';
    final crc = calculateCrc16(dataWithoutCrc);

    return '$dataWithoutCrc$crc';
  }

  /// Deep link URL for National Bank of Cambodia Bakong App
  static String getBakongDeepLink(String khqrPayload) {
    return 'bakong://qr?data=${Uri.encodeComponent(khqrPayload)}';
  }
}
