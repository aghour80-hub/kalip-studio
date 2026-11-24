import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/core/delivery/delivery_service.dart';
import 'package:style_house/core/payment/cod_service.dart';
import 'package:style_house/core/payment/khqr_service.dart';
import 'package:style_house/data/services/payment_service.dart';

void main() {
  group('Phase 5: Bakong KHQR Generator & CRC-16 Engine', () {
    test('calculateCrc16 computes standard CCITT 16-bit checksum', () {
      // Known CRC test string
      final crc = KhqrService.calculateCrc16('123456789');
      expect(crc.length, 4);
      expect(RegExp(r'^[0-9A-F]{4}$').hasMatch(crc), isTrue);
    });

    test('generateKhqrPayload produces standard EMVCo dynamic KHQR payload in USD', () {
      final payload = KhqrService.generateKhqrPayload(
        orderNumber: 'SH-2026-9999',
        amountUsd: 145.00,
        isKhr: false,
      );

      // Must start with Tag 00: 000201
      expect(payload, startsWith('000201'));
      // Dynamic QR (Tag 01: 010212)
      expect(payload, contains('010212'));
      // Bakong Merchant info Tag 29
      expect(payload, contains('kalipstudio@aclb'));
      // Clothing category 5691
      expect(payload, contains('52045691'));
      // Currency 840 (USD)
      expect(payload, contains('5303840'));
      // Amount 145.00
      expect(payload, contains('5406145.00'));
      // Country KH
      expect(payload, contains('5802KH'));
      // Merchant Name
      expect(payload, contains('KALIP STUDIO ATELIER'));
      // City Phnom Penh
      expect(payload, contains('PHNOM PENH'));
      // CRC tag prefix 6304 followed by 4 hex characters
      expect(payload, contains('6304'));
      final crcPart = payload.substring(payload.length - 4);
      expect(RegExp(r'^[0-9A-F]{4}$').hasMatch(crcPart), isTrue);
    });

    test('generateKhqrPayload produces standard EMVCo payload in KHR (Currency 116)', () {
      final payload = KhqrService.generateKhqrPayload(
        orderNumber: 'SH-2026-8888',
        amountUsd: 10.0,
        isKhr: true,
        exchangeRate: 4100.0,
      );

      // Currency 116 (KHR)
      expect(payload, contains('5303116'));
      // 10 * 4100 = 41000 KHR
      expect(payload, contains('540541000'));
    });

    test('getBakongDeepLink produces valid URL encoded Bakong deep link', () {
      final payload = KhqrService.generateKhqrPayload(
        orderNumber: 'SH-001',
        amountUsd: 50.0,
      );
      final deepLink = KhqrService.getBakongDeepLink(payload);

      expect(deepLink, startsWith('bakong://qr?data='));
      expect(deepLink, contains('000201'));
    });
  });

  group('Phase 5: Cash on Delivery (COD) Cambodian Engine', () {
    test('roundToNearest100Riels properly rounds to 100 Riel increments', () {
      expect(CodService.roundToNearest100Riels(4140.0), 4100);
      expect(CodService.roundToNearest100Riels(4160.0), 4200);
      expect(CodService.roundToNearest100Riels(594532.0), 594500);
      expect(CodService.roundToNearest100Riels(594578.0), 594600);
    });

    test('calculateCashBreakdown returns dual currency and note advice', () {
      final breakdown = CodService.calculateCashBreakdown(totalUsd: 145.0);

      expect(breakdown['total_usd'], 145.0);
      expect(breakdown['formatted_usd'], '\$145.00');
      expect(breakdown['total_khr'], 594500); // 145 * 4100 = 594,500
      expect(breakdown['formatted_khr'], '594,500 ៛');
    });

    test('getHandoverInstruction contains both USD and KHR in English and Khmer', () {
      final en = CodService.getHandoverInstructionEn(50.0);
      expect(en, contains('\$50.00'));
      expect(en, contains('205,000 ៛'));

      final km = CodService.getHandoverInstructionKm(50.0);
      expect(km, contains('\$50.00'));
      expect(km, contains('205,000 ៛'));
    });
  });

  group('Phase 5: Delivery & Courier Routing Service', () {
    test('Phnom Penh orders are routed to same-day express moto rider', () {
      final info = DeliveryService.getDeliveryDetails('Phnom Penh');

      expect(info.isSameDayAvailable, isTrue);
      expect(info.serviceType, contains('Same-Day'));
      expect(info.estimatedDuration, contains('2 – 4 Hours'));
      expect(info.dispatchHub, contains('BKK1'));

      final tracking = DeliveryService.generateTrackingCode('Phnom Penh', 'SH-2026-1049');
      expect(tracking, 'VET-PP-20261049');
    });

    test('Provincial orders (Siem Reap, Battambang) are routed to VET Express', () {
      final siemReapInfo = DeliveryService.getDeliveryDetails('Siem Reap');
      expect(siemReapInfo.providerName, contains('Virak Buntham'));
      expect(siemReapInfo.isSameDayAvailable, isFalse);
      expect(siemReapInfo.estimatedDuration, contains('24 – 48 Hours'));

      final tracking = DeliveryService.generateTrackingCode('Siem Reap', 'SH-2026-1049');
      expect(tracking, 'VET-PROV-20261049');
    });
  });

  group('Phase 5: Payment Service Server-Side Verification', () {
    test('verifyKhqrPaymentServerSide validates payment securely', () async {
      final service = PaymentService();
      final result = await service.verifyKhqrPaymentServerSide(
        orderId: 'ord-test-01',
        orderNumber: 'SH-2026-001',
        amountUsd: 75.0,
      );

      expect(result.isSuccessful, isTrue);
      expect(result.transactionRef, startsWith('BAKONG-TX-'));
      expect(result.status, PaymentVerificationStatus.verified);
    });
  });
}
