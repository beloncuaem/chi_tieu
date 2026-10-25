import 'package:flutter_test/flutter_test.dart';
import 'package:chi_tieu/core/utils/currency_formatter.dart';
import 'package:chi_tieu/core/utils/date_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Formats VND currency properly for various values', () {
      expect(CurrencyFormatter.format(35000), '35.000\u00a0đ');
      expect(CurrencyFormatter.format(1500000), '1.500.000\u00a0đ');
      expect(CurrencyFormatter.format(0), '0\u00a0đ');
      expect(CurrencyFormatter.format(100), '100\u00a0đ');
      expect(CurrencyFormatter.format(999999999), '999.999.999\u00a0đ');
    });
  });

  group('DateFormatter Tests', () {
    test('Formats today as "Hôm nay"', () {
      final now = DateTime.now();
      expect(DateFormatter.formatDate(now), 'Hôm nay');
    });

    test('Formats yesterday as "Hôm qua"', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 10, 0);
      expect(DateFormatter.formatDate(yesterday), 'Hôm qua');
    });

    test('Formats older date as dd/MM/yyyy', () {
      final pastDate = DateTime(2025, 5, 20);
      expect(DateFormatter.formatDate(pastDate), '20/05/2025');
    });

    test('Formats time as HH:mm', () {
      final time = DateTime(2026, 10, 14, 8, 5);
      expect(DateFormatter.formatTime(time), '08:05');

      final evening = DateTime(2026, 10, 14, 21, 45);
      expect(DateFormatter.formatTime(evening), '21:45');
    });
  });
}
