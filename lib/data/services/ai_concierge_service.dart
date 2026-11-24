import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/delivery/delivery_service.dart';
import 'package:style_house/data/models/chat_message_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/order_repository.dart';
import 'package:style_house/data/repositories/product_repository.dart';

class AiConciergeService {
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  AiConciergeService({
    ProductRepository? productRepository,
    OrderRepository? orderRepository,
  })  : _productRepository = productRepository ?? ProductRepository(),
        _orderRepository = orderRepository ?? OrderRepository();

  String get aiBackendUrl =>
      dotenv.env['AI_BACKEND_URL'] ?? 'https://api.stylehouse.com.kh/v1/ai-chat';

  /// Grounded AI response generation
  Future<ChatMessageModel> sendMessage({
    required String userQuery,
    required String userId,
    required bool isKhmer,
  }) async {
    final cleanQuery = userQuery.trim().toLowerCase();

    // 1. Order Status Tracking Inquiry
    final orderMatch = RegExp(r'(sh-\d{4}-\d+|exp-kh-\d+|vet-[a-z]+-\d+)', caseSensitive: false)
        .firstMatch(cleanQuery);

    if (orderMatch != null || cleanQuery.contains('order') || cleanQuery.contains('tracking') || cleanQuery.contains('កុម្ម៉ង់')) {
      final userOrders = await _orderRepository.getOrders(userId);

      if (userOrders.isNotEmpty) {
        OrderModel targetOrder = userOrders.first;
        if (orderMatch != null) {
          final matchedCode = orderMatch.group(0)!.toUpperCase();
          targetOrder = userOrders.firstWhere(
            (o) => o.orderNumber.toUpperCase() == matchedCode || o.trackingCode.toUpperCase() == matchedCode,
            orElse: () => userOrders.first,
          );
        }

        final deliveryInfo = DeliveryService.getDeliveryDetails(targetOrder.province ?? 'Phnom Penh');

        final responseText = isKhmer
            ? 'ការបញ្ជាទិញលេខ **${targetOrder.orderNumber}** របស់អ្នកស្ថិតក្នុងស្ថានភាព: **${targetOrder.status.titleKm}**។\n\n'
                '• ក្រុមហ៊ុនដឹកជញ្ជូន: ${deliveryInfo.providerName}\n'
                '• លេខកូដតាមដាន: `${targetOrder.trackingCode}`\n'
                '• រយៈពេលប៉ាន់ស្មាន: ${deliveryInfo.estimatedDuration}\n'
                '• ទីតាំងដឹកជញ្ជូន: ${targetOrder.deliveryAddress}\n\n'
                'តើមានអ្វីផ្សេងទៀតដែលខ្ញុំអាចជួយលោកអ្នកបានទេ?'
            : 'Your order **${targetOrder.orderNumber}** is currently: **${targetOrder.status.titleEn}**.\n\n'
                '• Courier Partner: ${deliveryInfo.providerName}\n'
                '• Tracking Code: `${targetOrder.trackingCode}`\n'
                '• Estimated Delivery: ${deliveryInfo.estimatedDuration}\n'
                '• Delivery Address: ${targetOrder.deliveryAddress}\n\n'
                'Can I assist you with anything else regarding your order?';

        return ChatMessageModel(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          text: responseText,
          sender: MessageSender.concierge,
          timestamp: DateTime.now(),
          relatedOrderId: targetOrder.orderNumber,
          suggestedActions: [
            isKhmer ? 'ពិនិត្យព័ត៌មានលម្អិត' : 'View Order Details',
            isKhmer ? 'ទាក់ទងអ្នកដឹកជញ្ជូន' : 'Contact Courier Hotline',
          ],
        );
      }
    }

    // 2. Specific Product Inquiry & Stock Verification
    final allProducts = await _productRepository.getProducts();
    ProductModel? matchedProduct;

    for (final p in allProducts) {
      final pName = p.nameEn.toLowerCase();
      if (cleanQuery.contains(pName) || cleanQuery.contains(p.id.toLowerCase())) {
        matchedProduct = p;
        break;
      }
      // Substring keyword matching
      final keywords = pName.split(' ').where((w) => w.length > 3);
      if (keywords.where((kw) => cleanQuery.contains(kw)).length >= 2) {
        matchedProduct = p;
        break;
      }
    }

    if (matchedProduct != null) {
      final inStock = matchedProduct.isInStock;
      final stockQty = matchedProduct.stockQuantity;
      final sizesStr = matchedProduct.sizes.join(', ');
      final colorsStr = matchedProduct.colors.map((c) => c.localizedName(isKhmer)).join(', ');

      final responseText = isKhmer
          ? 'ទំនិញ **${matchedProduct.localizedName(true)}** (${matchedProduct.nameEn}):\n\n'
              '• តម្លៃ: \$${matchedProduct.priceUsd.toStringAsFixed(2)} (≈ ${((matchedProduct.priceUsd * AppConstants.usdToKhrRate) / 100).round() * 100} ៛)\n'
              '• ស្តុក: ${inStock ? "មានក្នុងស្តុក ($stockQty ឈុតនៅ BKK1 Atelier)" : "អស់ពីស្តុកបណ្តោះអាសន្ន"}\n'
              '• ទំហំដែលមាន: $sizesStr\n'
              '• ពណ៌: $colorsStr\n'
              '• សាច់ក្រណាត់: ${matchedProduct.localizedMaterial(true)}\n\n'
              'តើលោកអ្នកចង់បន្ថែមទំនិញនេះទៅក្នុងកន្ត្រកទេ?'
          : 'Regarding **${matchedProduct.nameEn}**:\n\n'
              '• Price: \$${matchedProduct.priceUsd.toStringAsFixed(2)} (≈ ${((matchedProduct.priceUsd * AppConstants.usdToKhrRate) / 100).round() * 100} ៛)\n'
              '• Stock Status: ${inStock ? "In Stock ($stockQty units ready at BKK1 Flagship)" : "Currently Sold Out"}\n'
              '• Available Sizes: $sizesStr\n'
              '• Colors: $colorsStr\n'
              '• Material & Craft: ${matchedProduct.materialEn}\n\n'
              'Would you like me to guide you through adding this piece to your shopping bag?';

      return ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        sender: MessageSender.concierge,
        timestamp: DateTime.now(),
        relatedProductId: matchedProduct.id,
        suggestedActions: [
          isKhmer ? 'មើលព័ត៌មានលម្អិត' : 'View Product Details',
          isKhmer ? 'បន្ថែមទៅកន្ត្រក' : 'Add to Bag',
        ],
      );
    }

    // 3. Payment Inquiry (KHQR / COD / Bakong)
    if (cleanQuery.contains('payment') || cleanQuery.contains('khqr') || cleanQuery.contains('bakong') || cleanQuery.contains('cod') || cleanQuery.contains('ទូទាត់')) {
      final responseText = isKhmer
          ? 'វិធីសាស្ត្រទូទាត់ប្រាក់នៅ **KALIP studio**:\n\n'
              '• **KHQR (Bakong National QR)**: ស្កេនទូទាត់ភ្លាមៗជាមួយគ្រប់កម្មវិធីធនាគារក្នុងស្រុក (ABA, Wing, ACLEDA, Sathapana...)\n'
              '• **Cash on Delivery (COD)**: ទូទាត់ជាប្រាក់សុទ្ធជាដុល្លារ (USD) ឬប្រាក់រៀល (KHR) ពេលទំនិញប្រគល់ដល់ដៃ។\n'
              '• **អត្រាប្តូរប្រាក់**: ១ ដុល្លារ = ៤,១០០ រៀល (មានការបង្គត់ត្រឹម ១០០ រៀលស្របតាមទម្លាប់សាច់ប្រាក់ក្នុងស្រុក)។'
          : 'Payment Options at **KALIP studio**:\n\n'
              '• **KHQR (Bakong National QR)**: Instant zero-fee mobile payment scan compatible with all Cambodian banks (ABA, Wing, ACLEDA, etc.).\n'
              '• **Cash on Delivery (COD)**: Pay upon receiving your package in either USD or Cambodian Riel (KHR).\n'
              '• **Exchange Rate**: Configured at 1 USD = 4,100 KHR with 100-Riel customary cash rounding.';

      return ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        sender: MessageSender.concierge,
        timestamp: DateTime.now(),
        suggestedActions: [
          isKhmer ? 'វិធីបង់ប្រាក់ KHQR' : 'How to Pay via KHQR',
          isKhmer ? 'មើលកន្ត្រកទំនិញ' : 'Go to Shopping Bag',
        ],
      );
    }

    // 4. Cambodian Shipping Policy Inquiry
    if (cleanQuery.contains('shipping') || cleanQuery.contains('delivery') || cleanQuery.contains('ដឹកជញ្ជូន') || cleanQuery.contains('vet')) {
      final responseText = isKhmer
          ? 'គោលការណ៍ដឹកជញ្ជូនរបស់ **KALIP studio** នៅកម្ពុជា:\n\n'
              '• **រាជធានីភ្នំពេញ**: ដឹកជញ្ជូនរហ័សក្នុងថ្ងៃតែមួយ (២ – ៤ ម៉ោង) ដោយអ្នកជិះម៉ូតូផ្ទាល់ពី BKK1 Atelier។\n'
              '• **បណ្តាខេត្ត** (សៀមរាប, បាត់ដំបង, ព្រះសីហនុ, កំពត...): រយៈពេល ២៤ – ៤៨ ម៉ោង តាមរយៈ Virak Buntham (VET) Express។\n'
              '• **ឥតគិតថ្លៃដឹកជញ្ជូន**: សម្រាប់រាល់ការបញ្ជាទិញចាប់ពី \$${AppConstants.freeShippingThresholdUsd.toInt()} ឡើងទៅ (ក្រោមនេះថ្លៃសេវាត្រឹម \$${AppConstants.standardShippingFeeUsd.toStringAsFixed(2)})។'
          : 'KALIP studio Cambodia Shipping & Delivery Policy:\n\n'
              '• **Phnom Penh**: Same-day express courier (2 – 4 hours) dispatched directly from our BKK1 Flagship Atelier.\n'
              '• **Provinces** (Siem Reap, Battambang, Sihanoukville, Kampot, Kandal): 24 – 48 hours via Virak Buntham (VET) Express Cambodia.\n'
              '• **Free Delivery**: On all orders over \$${AppConstants.freeShippingThresholdUsd.toInt()} (Standard shipping is \$${AppConstants.standardShippingFeeUsd.toStringAsFixed(2)}).';

      return ChatMessageModel(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        sender: MessageSender.concierge,
        timestamp: DateTime.now(),
        suggestedActions: [
          isKhmer ? 'តាមដានការកុម្ម៉ង់' : 'Track Existing Order',
          isKhmer ? 'ទីតាំងហាង BKK1' : 'BKK1 Flagship Location',
        ],
      );
    }

    // 5. Default Luxury Fashion Styling Response
    final responseText = isKhmer
        ? 'សូមស្វាគមន៍មកកាន់ **KALIP studio Luxury Concierge**!\n\n'
            'ខ្ញុំអាចជួយលោកអ្នកអំពី:\n'
            '• ព័ត៌មានអំពីទំហំ ពណ៌ និងស្តុកទំនិញសូត្រខ្មែរ និងក្រណាត់ទេសឯក\n'
            '• តាមដានស្ថានភាពកុម្ម៉ង់ទំនិញ និងព័ត៌មានដឹកជញ្ជូន (VET Express)\n'
            '• គោលការណ៍ប្តូរទំនិញក្នុងរយៈពេល ៧ ថ្ងៃ\n'
            '• ការណែនាំអំពីការថែទាំសាច់ក្រណាត់សូត្រប្រណីត\n\n'
            'តើខ្ញុំអាចជួយអ្វីលោកអ្នកថ្ងៃនេះ?'
        : 'Welcome to the **KALIP studio Fashion Concierge**!\n\n'
            'I am delighted to assist you with:\n'
            '• Stock availability, sizing guides, and colors for our Cambodian silk and linen collections\n'
            '• Real-time delivery status for Phnom Penh and provincial courier orders\n'
            '• Fabric care instructions for handwoven Khmer silk\n'
            '• 7-day atelier exchange policy and BKK1 boutique appointments\n\n'
            'How may I elevate your shopping experience today?';

    return ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      sender: MessageSender.concierge,
      timestamp: DateTime.now(),
      suggestedActions: [
        isKhmer ? 'ពិនិត្យស្តុកទំនិញថ្មី' : 'Check New Arrivals Stock',
        isKhmer ? 'គោលការណ៍ដឹកជញ្ជូន' : 'Delivery & Courier Policy',
        isKhmer ? 'វិធីសាស្ត្រទូទាត់ប្រាក់' : 'Payment Methods (KHQR)',
      ],
    );
  }
}
