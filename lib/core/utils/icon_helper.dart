import 'package:flutter/material.dart';

class IconHelper {
  static final Map<String, IconData> _iconRegistry = {
    'forkKnife': Icons.restaurant_rounded,
    'coffee': Icons.local_cafe_rounded,
    'car': Icons.directions_car_rounded,
    'shoppingBag': Icons.shopping_bag_rounded,
    'receipt': Icons.receipt_long_rounded,
    'gameController': Icons.sports_esports_rounded,
    'heartbeat': Icons.favorite_rounded,
    'graduationCap': Icons.school_rounded,
    'house': Icons.home_rounded,
    'airplaneTilt': Icons.flight_rounded,
    'gift': Icons.card_giftcard_rounded,
    'pawPrint': Icons.pets_rounded,
    'barbell': Icons.fitness_center_rounded,
    'filmStrip': Icons.movie_rounded,
    'tShirt': Icons.checkroom_rounded,
    'deviceMobile': Icons.smartphone_rounded,
    'bank': Icons.account_balance_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'dotsThreeOutline': Icons.more_horiz_rounded,
  };

  // Ánh xạ từ các emoji cũ sang icon tương ứng
  static final Map<String, String> _emojiToIconName = {
    '🍜': 'forkKnife',
    '🍲': 'forkKnife',
    '🍔': 'forkKnife',
    '🍕': 'forkKnife',
    '☕': 'coffee',
    '🚗': 'car',
    '🛵': 'car',
    '🚌': 'car',
    '🛍️': 'shoppingBag',
    '🛒': 'shoppingBag',
    '⚡': 'receipt',
    '💡': 'receipt',
    '🧾': 'receipt',
    '🎮': 'gameController',
    '💊': 'heartbeat',
    '🏥': 'heartbeat',
    '📚': 'graduationCap',
    '🏠': 'house',
    '✈️': 'airplaneTilt',
    '🎁': 'gift',
  };

  static List<String> get availableIcons => _iconRegistry.keys.toList();

  static String normalizeIconKey(String iconKey) {
    final mappedKey = _emojiToIconName[iconKey] ?? iconKey;
    return _iconRegistry.containsKey(mappedKey) ? mappedKey : 'dotsThreeOutline';
  }

  static Widget getIconWidget(
    String iconKey, {
    double size = 22,
    Color? color,
  }) {
    final mappedKey = _emojiToIconName[iconKey] ?? iconKey;
    final iconData = _iconRegistry[mappedKey];

    if (iconData != null) {
      return Icon(iconData, size: size, color: color);
    }

    // Nếu iconKey là chuỗi emoji
    if (iconKey.runes.length <= 2 && !iconKey.contains(RegExp(r'[a-zA-Z]'))) {
      return Text(iconKey, style: TextStyle(fontSize: size * 0.9));
    }

    return Icon(Icons.label_outline_rounded, size: size, color: color);
  }

  static Color parseColor(
    String? colorHex, {
    Color defaultColor = const Color(0xFF10B981),
  }) {
    if (colorHex == null || colorHex.isEmpty) return defaultColor;
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return defaultColor;
  }
}
