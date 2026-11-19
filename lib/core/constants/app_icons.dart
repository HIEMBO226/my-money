import 'package:material_ui/material_ui.dart';

abstract final class AppIcons {
  static const List<IconData> accountIcons = [
    Icons.payments,
    Icons.account_balance,
    Icons.phone_android,
    Icons.savings,
    Icons.account_balance_wallet,
    Icons.credit_card,
  ];

  static const List<IconData> categoryIcons = [
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.directions_car,
    Icons.home,
    Icons.local_hospital,
    Icons.movie,
    Icons.shopping_bag,
    Icons.receipt_long,
    Icons.school,
    Icons.flight,
    Icons.fitness_center,
    Icons.pets,
    Icons.wifi,
    Icons.local_gas_station,
    Icons.local_cafe,
    Icons.work,
    Icons.laptop_mac,
    Icons.trending_up,
    Icons.card_giftcard,
    Icons.attach_money,
    Icons.sell,
    Icons.category,
  ];

  static const List<IconData> allIcons = [
    ...accountIcons,
    ...categoryIcons,
  ];

  /// Maps a persisted icon codePoint back to a constant [IconData]
  /// so Flutter icon tree-shaking works reliably in release builds.
  static IconData fromCodePoint(int codePoint) {
    for (final icon in allIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }
    return Icons.category;
  }
}
