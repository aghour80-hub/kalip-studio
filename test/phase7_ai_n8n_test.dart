import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/chat_message_model.dart';
import 'package:style_house/data/repositories/order_repository.dart';
import 'package:style_house/data/repositories/product_repository.dart';
import 'package:style_house/data/services/ai_concierge_service.dart';
import 'package:style_house/data/services/n8n_webhook_service.dart';
import 'package:style_house/presentation/providers/ai_chat_provider.dart';

void main() {
  group('Phase 7: AI Concierge Fashion Advisor', () {
    late AiConciergeService conciergeService;

    setUp(() {
      conciergeService = AiConciergeService(
        productRepository: ProductRepository(),
        orderRepository: OrderRepository(),
      );
    });

    test('Concierge answers product stock inquiries with real catalog grounding', () async {
      final response = await conciergeService.sendMessage(
        userQuery: 'Do you have the Atelier Silk Wrap Midi Dress in stock?',
        userId: 'user-001',
        isKhmer: false,
      );

      expect(response.sender, MessageSender.concierge);
      expect(response.text, contains('Atelier Silk Wrap Midi Dress'));
      expect(response.text, contains('In Stock'));
      expect(response.text, contains('\$185.00'));
      expect(response.relatedProductId, isNotNull);
    });

    test('Concierge responds to Cambodian delivery & shipping questions', () async {
      final responseEn = await conciergeService.sendMessage(
        userQuery: 'What is your shipping policy in Phnom Penh and provinces?',
        userId: 'user-001',
        isKhmer: false,
      );

      expect(responseEn.text, contains('Phnom Penh'));
      expect(responseEn.text, contains('Same-day'));
      expect(responseEn.text, contains('Virak Buntham (VET) Express'));

      final responseKm = await conciergeService.sendMessage(
        userQuery: 'តើមានសេវាដឹកជញ្ជូនដល់ខេត្តទេ?',
        userId: 'user-001',
        isKhmer: true,
      );

      expect(responseKm.text, contains('រាជធានីភ្នំពេញ'));
      expect(responseKm.text, contains('Virak Buntham'));
    });

    test('Concierge tracks existing order by order number', () async {
      final sampleOrder = SampleData.sampleOrders.first;
      final response = await conciergeService.sendMessage(
        userQuery: 'Where is my order ${sampleOrder.orderNumber}?',
        userId: 'user-vip',
        isKhmer: false,
      );

      expect(response.text, contains(sampleOrder.orderNumber));
      expect(response.relatedOrderId, sampleOrder.orderNumber);
    });

    test('Concierge explains KHQR and Cash on Delivery payment options', () async {
      final response = await conciergeService.sendMessage(
        userQuery: 'Can I pay via KHQR Bakong or Cash on Delivery?',
        userId: 'user-001',
        isKhmer: false,
      );

      expect(response.text, contains('KHQR'));
      expect(response.text, contains('Bakong'));
      expect(response.text, contains('Cash on Delivery'));
    });
  });

  group('Phase 7: n8n Automation Webhook Service', () {
    late N8nWebhookService webhookService;

    setUp(() {
      webhookService = N8nWebhookService();
    });

    test('notifyOrderCreated formats and dispatches comprehensive payload', () async {
      final sampleOrder = SampleData.sampleOrders.first;
      final event = await webhookService.notifyOrderCreated(sampleOrder);

      expect(event.eventType, 'order_created');
      expect(event.isSuccessful, isTrue);

      final payload = event.payload;
      expect(payload['order_number'], sampleOrder.orderNumber);
      expect(payload['financials']['total_usd'], sampleOrder.totalUsd);
      expect(payload['delivery']['tracking_code'], sampleOrder.trackingCode);
      expect(payload['items'], isNotEmpty);
    });

    test('notifyPaymentVerified logs verified transaction reference', () async {
      final event = await webhookService.notifyPaymentVerified(
        orderNumber: 'SH-2026-9090',
        transactionRef: 'BAKONG-TX-12345678',
        amountUsd: 145.0,
      );

      expect(event.eventType, 'payment_verified');
      expect(event.payload['order_number'], 'SH-2026-9090');
      expect(event.payload['transaction_ref'], 'BAKONG-TX-12345678');
    });

    test('notifyLowInventory creates alert for restocking BKK1 atelier', () async {
      final event = await webhookService.notifyLowInventory(
        productId: 'prod-dress-01',
        productName: 'Royal Silk Dress',
        remainingUnits: 2,
      );

      expect(event.eventType, 'inventory_low');
      expect(event.payload['remaining_units'], 2);
      expect(event.payload['location'], contains('BKK1'));
    });
  });

  group('Phase 7: AiChatNotifier State Management', () {
    test('AiChatNotifier updates messages and clears history', () async {
      final notifier = AiChatNotifier();
      expect(notifier.state.messages.isNotEmpty, isTrue);

      await notifier.sendUserMessage(
        query: 'What materials do you use?',
        userId: 'user-001',
        isKhmer: false,
      );

      // Should have initial welcome + user query + concierge response = 3 messages
      expect(notifier.state.messages.length, greaterThanOrEqualTo(3));
      expect(notifier.state.isLoading, isFalse);

      notifier.clearHistory();
      expect(notifier.state.messages.isEmpty, isTrue);
    });
  });
}
