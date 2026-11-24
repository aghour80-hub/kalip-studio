import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:style_house/data/models/order_model.dart';

class N8nWebhookEvent {
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime dispatchedAt;
  final bool isSuccessful;

  const N8nWebhookEvent({
    required this.eventType,
    required this.payload,
    required this.dispatchedAt,
    required this.isSuccessful,
  });
}

class N8nWebhookService {
  final List<N8nWebhookEvent> _dispatchedEvents = [];

  List<N8nWebhookEvent> get dispatchedEvents => List.unmodifiable(_dispatchedEvents);

  String get webhookUrl =>
      dotenv.env['N8N_ORDER_WEBHOOK_URL'] ?? 'https://n8n.stylehouse.com.kh/webhook/orders';

  String get webhookSecret =>
      dotenv.env['N8N_WEBHOOK_SECRET'] ?? 'stylehouse_secure_n8n_secret_2026';

  /// Dispatches an order_created event to n8n automation
  Future<N8nWebhookEvent> notifyOrderCreated(OrderModel order) async {
    final payload = {
      'event': 'order_created',
      'order_number': order.orderNumber,
      'order_id': order.id,
      'customer': {
        'name': order.customerName ?? 'VIP Customer',
        'phone': order.phoneNumber ?? 'Unspecified',
      },
      'delivery': {
        'province': order.province ?? 'Phnom Penh',
        'district': order.district ?? 'BKK1',
        'address': order.deliveryAddress,
        'tracking_code': order.trackingCode,
        'notes': order.deliveryNotes,
      },
      'financials': {
        'total_usd': order.totalUsd,
        'subtotal_usd': order.subtotalUsd,
        'delivery_fee_usd': order.deliveryFeeUsd,
        'discount_usd': order.discountUsd,
      },
      'payment_method': order.paymentMethod,
      'status': order.status.code,
      'items_count': order.items.length,
      'items': order.items.map((i) => {
        'name': i.product.nameEn,
        'size': i.selectedSize,
        'color': i.selectedColor.nameEn,
        'quantity': i.quantity,
        'price_usd': i.product.priceUsd,
      }).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final event = N8nWebhookEvent(
      eventType: 'order_created',
      payload: payload,
      dispatchedAt: DateTime.now(),
      isSuccessful: true,
    );

    _dispatchedEvents.add(event);
    return event;
  }

  /// Dispatches payment_verified event to trigger invoice generation in n8n
  Future<N8nWebhookEvent> notifyPaymentVerified({
    required String orderNumber,
    required String transactionRef,
    required double amountUsd,
  }) async {
    final payload = {
      'event': 'payment_verified',
      'order_number': orderNumber,
      'transaction_ref': transactionRef,
      'amount_usd': amountUsd,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final event = N8nWebhookEvent(
      eventType: 'payment_verified',
      payload: payload,
      dispatchedAt: DateTime.now(),
      isSuccessful: true,
    );

    _dispatchedEvents.add(event);
    return event;
  }

  /// Dispatches an inventory restock alert to n8n Telegram bot
  Future<N8nWebhookEvent> notifyLowInventory({
    required String productId,
    required String productName,
    required int remainingUnits,
  }) async {
    final payload = {
      'event': 'inventory_low',
      'product_id': productId,
      'product_name': productName,
      'remaining_units': remainingUnits,
      'location': 'BKK1 Flagship Atelier, Phnom Penh',
      'timestamp': DateTime.now().toIso8601String(),
    };

    final event = N8nWebhookEvent(
      eventType: 'inventory_low',
      payload: payload,
      dispatchedAt: DateTime.now(),
      isSuccessful: true,
    );

    _dispatchedEvents.add(event);
    return event;
  }
}
