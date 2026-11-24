class DeliveryInfo {
  final String providerName;
  final String serviceType;
  final String estimatedDuration;
  final String hotline;
  final String dispatchHub;
  final bool isSameDayAvailable;

  const DeliveryInfo({
    required this.providerName,
    required this.serviceType,
    required this.estimatedDuration,
    required this.hotline,
    required this.dispatchHub,
    required this.isSameDayAvailable,
  });
}

class DeliveryService {
  /// Evaluates delivery SLA and courier logistics based on destination province
  static DeliveryInfo getDeliveryDetails(String province) {
    final cleanProvince = province.trim().toLowerCase();

    if (cleanProvince.contains('phnom penh')) {
      return const DeliveryInfo(
        providerName: 'KALIP studio Express Courier (Moto Rider)',
        serviceType: 'Phnom Penh Same-Day Express',
        estimatedDuration: '2 – 4 Hours (Same Day)',
        hotline: '+855 (0) 92 888 999',
        dispatchHub: 'BKK1 Flagship Atelier, Street 302, Phnom Penh',
        isSameDayAvailable: true,
      );
    }

    if (cleanProvince.contains('kandal')) {
      return const DeliveryInfo(
        providerName: 'KALIP studio Metro Courier',
        serviceType: 'Greater Phnom Penh Delivery',
        estimatedDuration: 'Same Day / Next Morning',
        hotline: '+855 (0) 92 888 999',
        dispatchHub: 'BKK1 Flagship Atelier, Phnom Penh',
        isSameDayAvailable: true,
      );
    }

    // Provincial delivery via Virak Buntham VET Express / J&T Express
    return const DeliveryInfo(
      providerName: 'Virak Buntham (VET) Express Cambodia',
      serviceType: 'Provincial VIP Express',
      estimatedDuration: '24 – 48 Hours (1 – 2 Business Days)',
      hotline: '+855 (0) 23 999 999',
      dispatchHub: 'VET Central Logistics Hub, Phnom Penh',
      isSameDayAvailable: false,
    );
  }

  /// Generates a standardized Cambodian courier tracking code
  static String generateTrackingCode(String province, String orderNumber) {
    final prefix = province.toLowerCase().contains('phnom penh') ? 'VET-PP' : 'VET-PROV';
    final suffix = orderNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return '$prefix-$suffix';
  }
}
