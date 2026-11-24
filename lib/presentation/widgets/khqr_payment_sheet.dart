import 'dart:async';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/payment/cod_service.dart';
import 'package:style_house/core/payment/khqr_service.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/services/n8n_webhook_service.dart';
import 'package:style_house/data/services/payment_service.dart';

class KhqrPaymentSheet extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onPaymentSuccess;

  const KhqrPaymentSheet({
    super.key,
    required this.order,
    required this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required OrderModel order,
    required VoidCallback onPaymentSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KhqrPaymentSheet(
        order: order,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<KhqrPaymentSheet> {
  final PaymentService _paymentService = PaymentService();
  late String _khqrPayload;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  bool _isVerifying = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 300; // 5 minutes validity
    _khqrPayload = KhqrService.generateKhqrPayload(
      orderNumber: widget.order.orderNumber,
      amountUsd: widget.order.totalUsd,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verifyPayment() async {
    setState(() => _isVerifying = true);

    final result = await _paymentService.verifyKhqrPaymentServerSide(
      orderId: widget.order.id,
      orderNumber: widget.order.orderNumber,
      amountUsd: widget.order.totalUsd,
    );

    if (result.isSuccessful && mounted) {
      // Trigger n8n payment verified webhook
      N8nWebhookService().notifyPaymentVerified(
        orderNumber: widget.order.orderNumber,
        transactionRef: result.transactionRef,
        amountUsd: widget.order.totalUsd,
      );

      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.of(context).pop();
        widget.onPaymentSuccess();
      }
    } else if (mounted) {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = CodService.calculateCashBreakdown(totalUsd: widget.order.totalUsd);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // KHQR Brand Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA2D2D), // KHQR Red
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'KHQR',
                  style: TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Bakong National QR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'KALIP studio ATELIER — PHNOM PENH',
            style: AppTypography.bodySmall(color: AppColors.luxuryBeigeDark),
          ),
          const SizedBox(height: 16),

          // Dual Price Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.canvasLinen,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                    Text(
                      CurrencyFormatter.format(widget.order.totalUsd, AppCurrency.usd),
                      style: AppTypography.priceTag(fontSize: 20),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Cambodian Riel', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                    Text(
                      breakdown['formatted_khr'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // QR Code Frame
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderMedium, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _khqrPayload,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryBlack,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),

              // Success Overlay
              if (_isSuccess)
                Container(
                  width: 232,
                  height: 232,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 54),
                      SizedBox(height: 8),
                      Text(
                        'Payment Verified!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Expiration & Bill Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                'Valid for: $_formattedTimer',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Ref: ${widget.order.orderNumber}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          if (!_isSuccess) ...[
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyPayment,
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                    )
                  : const Text(
                      'I HAVE SCANNED & TRANSFERRED',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _khqrPayload));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('KHQR Payload copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy, size: 16),
                  SizedBox(width: 8),
                  Text('COPY QR DATA / DEEP LINK', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
