import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/data/mock/sample_data.dart';

void main() {
  group('Currency & Formatting Tests', () {
    test('USD Formatting', () {
      final formatted = CurrencyFormatter.format(100.0, AppCurrency.usd);
      expect(formatted, '\$100.00');
    });

    test('KHR Formatting with 4,100 exchange rate and rounding', () {
      final formatted = CurrencyFormatter.format(100.0, AppCurrency.khr);
      expect(formatted.contains('410,000'), isTrue);
      expect(formatted.contains('៛'), isTrue);
    });

    test('Dual format shows both USD and KHR', () {
      final dual = CurrencyFormatter.formatDual(50.0);
      expect(dual.contains('\$50.00'), isTrue);
      expect(dual.contains('205,000'), isTrue);
    });
  });

  group('Sample Data Integrity Tests', () {
    test('Products have valid prices and Cambodia atelier details', () {
      expect(SampleData.products.isNotEmpty, isTrue);
      for (final product in SampleData.products) {
        expect(product.priceUsd, greaterThan(0));
        expect(product.nameEn.isNotEmpty, isTrue);
        expect(product.nameKm.isNotEmpty, isTrue);
        expect(product.colors.isNotEmpty, isTrue);
        expect(product.sizes.isNotEmpty, isTrue);
        expect(product.images.isNotEmpty, isTrue);
      }
    });

    test('Categories cover core fashion pillars', () {
      final categoryIds = SampleData.categories.map((c) => c.id).toList();
      expect(categoryIds.contains('women'), isTrue);
      expect(categoryIds.contains('men'), isTrue);
      expect(categoryIds.contains('bags'), isTrue);
    });
  });
}
