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
    _remainingSeconds = 600; // 10 minutes validity window
    _khqrPayload = KhqrService.generateKhqrPayload(
      orderNumber: widget.order.orderNumber,
      amountUsd: widget.order.totalUsd,
      exchangeRate: CurrencyFormatter.liveExchangeRate,
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
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

  void _copyValue(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ($value) copied!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFullscreenQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  KhqrService.abaQrAssetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.pureWhite,
                    padding: const EdgeInsets.all(24),
                    child: QrImageView(
                      data: _khqrPayload,
                      size: 260,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPayment() async {
    setState(() => _isVerifying = true);

    final result = await _paymentService.verifyKhqrPaymentServerSide(
      orderId: widget.order.id,
      orderNumber: widget.order.orderNumber,
      amountUsd: widget.order.totalUsd,
    );

    if (result.isSuccessful && mounted) {
      N8nWebhookService().notifyPaymentVerified(
        orderNumber: widget.order.orderNumber,
        transactionRef: result.transactionRef,
        amountUsd: widget.order.totalUsd,
      );

      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 1000));
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
    final rate = CurrencyFormatter.liveExchangeRate;
    final khrRounded = CodService.roundToNearest100Riels(widget.order.totalUsd * rate);
    final khrFormatted =
        '${khrRounded.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ៛';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
              const SizedBox(height: 14),

              // ABA / KHQR Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005B7F), // ABA Deep Blue
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      "ABA' KHQR",
                      style: TextStyle(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    KhqrService.abaAccountName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Text(
                'Quét mã QR bên dưới bằng ABA Mobile hoặc App Ngân hàng để chuyển khoản',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              // Dual Price Badge (Amount to transfer)
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
                    InkWell(
                      onTap: () => _copyValue('Amount USD', widget.order.totalUsd.toStringAsFixed(2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số tiền USD (Chạm để copy)', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                          Row(
                            children: [
                              Text(
                                CurrencyFormatter.format(widget.order.totalUsd, AppCurrency.usd),
                                style: AppTypography.priceTag(fontSize: 20),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 13, color: AppColors.luxuryBeigeDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _copyValue('Amount KHR', khrRounded.toString()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Hoặc Riel (KHR)', style: AppTypography.bodySmall(color: AppColors.textMuted)),
                          Row(
                            children: [
                              Text(
                                khrFormatted,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 13, color: AppColors.luxuryBeigeDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Authentic Store Owner ABA QR Image Frame (Tap to Zoom)
              Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    onTap: () => _showFullscreenQr(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 390),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF005B7F).withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Image.asset(
                              KhqrService.abaQrAssetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: QrImageView(
                                  data: _khqrPayload,
                                  version: QrVersions.auto,
                                  size: 200,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: const Color(0xFF005B7F).withValues(alpha: 0.08),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.zoom_in, size: 14, color: Color(0xFF005B7F)),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Chạm để phóng to QR (Tap to zoom)',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF005B7F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Payment Confirmed Overlay
                  if (_isSuccess)
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 58),
                          SizedBox(height: 10),
                          Text(
                            'Đã xác nhận thanh toán!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Payment Verified',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Copy Account Number Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.copy, size: 14, color: Color(0xFF005B7F)),
                    label: const Text(
                      'Copy USD: ${KhqrService.abaAccountUsd}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.canvasLinen,
                    onPressed: () => _copyValue('ABA USD Account', KhqrService.abaAccountUsdRaw),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.copy, size: 14, color: Color(0xFF005B7F)),
                    label: const Text(
                      'Copy KHR: ${KhqrService.abaAccountKhr}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.canvasLinen,
                    onPressed: () => _copyValue('ABA KHR Account', KhqrService.abaAccountKhrRaw),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Expiration & Order Reference
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Hạn giao dịch: $_formattedTimer',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _copyValue('Order Ref', widget.order.orderNumber),
                    child: Text(
                      'Nội dung CK: ${widget.order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Actions
              if (!_isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isVerifying ? null : _verifyPayment,
                    icon: _isVerifying
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      _isVerifying ? 'Đang xác nhận...' : 'TÔI ĐÃ CHUYỂN KHOẢN (CONFIRM)',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Đóng / Xem mã QR sau trong chi tiết đơn hàng',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
