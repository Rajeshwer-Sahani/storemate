import 'package:flutter/material.dart';

/// Defines the visual category used for displaying a product.
enum ProductVisualType {
  headphones,
  smartphone,
  charger,
  speaker,
  smartwatch,
  laptop,
  tablet,
  powerBank,
  cable,
  accessories,
  defaultProduct,
}

/// Reusable product icon configuration.
class ProductIconData {
  const ProductIconData({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;

  /// Light-mode background color.
  ///
  /// Do not use this directly when building UI.
  /// Use [ProductIconResolver.backgroundColor] instead so
  /// dark mode can be handled automatically.
  final Color backgroundColor;
}

/// Centralized product icon resolver.
///
/// This keeps product visual logic in one place so the same
/// iconography can be reused across Inventory, Billing,
/// Dashboard, Product Details, etc.
class ProductIconResolver {
  const ProductIconResolver._();

  static ProductIconData resolve(Map<String, dynamic> product) {
    final name = (product['name'] ?? '').toString();
    final brand = (product['brand'] ?? '').toString();

    final categoryData = product['product_categories'];

    final category = categoryData is Map
        ? (categoryData['name'] ?? '').toString()
        : '';

    return resolveFromText(name: name, brand: brand, category: category);
  }

  static ProductIconData resolveFromText({
    String? name,
    String? brand,
    String? category,
  }) {
    final searchText = [
      name ?? '',
      brand ?? '',
      category ?? '',
    ].join(' ').trim().toLowerCase();

    if (_containsAny(searchText, [
      'headphone',
      'headphones',
      'headset',
      'earphone',
      'earphones',
      'earbud',
      'earbuds',
      'airpods',
    ])) {
      return const ProductIconData(
        icon: Icons.headphones_rounded,
        color: Color(0xFF7C3AED),
        backgroundColor: Color(0xFFF0E7FF),
      );
    }

    if (_containsAny(searchText, [
      'mobile',
      'phone',
      'smartphone',
      'iphone',
      'android',
    ])) {
      return const ProductIconData(
        icon: Icons.smartphone_rounded,
        color: Color(0xFF2563EB),
        backgroundColor: Color(0xFFE8F0FF),
      );
    }

    if (_containsAny(searchText, [
      'charger',
      'charging',
      'adapter',
      'power adapter',
    ])) {
      return const ProductIconData(
        icon: Icons.power_rounded,
        color: Color(0xFF0F766E),
        backgroundColor: Color(0xFFE2F5F2),
      );
    }

    if (_containsAny(searchText, [
      'speaker',
      'soundbar',
      'bluetooth speaker',
    ])) {
      return const ProductIconData(
        icon: Icons.speaker_rounded,
        color: Color(0xFFEA580C),
        backgroundColor: Color(0xFFFFEDE3),
      );
    }

    if (_containsAny(searchText, ['watch', 'smartwatch', 'smart watch'])) {
      return const ProductIconData(
        icon: Icons.watch_rounded,
        color: Color(0xFF4F46E5),
        backgroundColor: Color(0xFFEBEAFF),
      );
    }

    if (_containsAny(searchText, ['laptop', 'notebook', 'macbook'])) {
      return const ProductIconData(
        icon: Icons.laptop_mac_rounded,
        color: Color(0xFF9333EA),
        backgroundColor: Color(0xFFF3E8FF),
      );
    }

    if (_containsAny(searchText, ['tablet', 'ipad'])) {
      return const ProductIconData(
        icon: Icons.tablet_mac_rounded,
        color: Color(0xFF0891B2),
        backgroundColor: Color(0xFFE5F8FC),
      );
    }

    if (_containsAny(searchText, ['power bank', 'powerbank'])) {
      return const ProductIconData(
        icon: Icons.battery_charging_full_rounded,
        color: Color(0xFF16A34A),
        backgroundColor: Color(0xFFE8F8EC),
      );
    }

    if (_containsAny(searchText, ['cable', 'usb', 'wire'])) {
      return const ProductIconData(
        icon: Icons.cable_rounded,
        color: Color(0xFFCA8A04),
        backgroundColor: Color(0xFFFFF7D9),
      );
    }

    if (_containsAny(searchText, [
      'accessory',
      'accessories',
      'case',
      'cover',
      'screen protector',
    ])) {
      return const ProductIconData(
        icon: Icons.category_rounded,
        color: Color(0xFFDB2777),
        backgroundColor: Color(0xFFFCE7F3),
      );
    }

    return const ProductIconData(
      icon: Icons.inventory_2_outlined,
      color: Color(0xFF2563EB),
      backgroundColor: Color(0xFFE8F0FF),
    );
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  // ---------------------------------------------------------------------------
  // Theme-aware background
  // ---------------------------------------------------------------------------

  /// Returns the appropriate icon background for the current theme.
  ///
  /// Light mode:
  /// Uses the predefined soft pastel background.
  ///
  /// Dark mode:
  /// Uses the current theme surface with a subtle tint from the
  /// product icon color, avoiding bright pastel blocks.
  static Color backgroundColor(BuildContext context, ProductIconData iconData) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (theme.brightness == Brightness.light) {
      return iconData.backgroundColor;
    }

    return Color.alphaBlend(
      iconData.color.withValues(alpha: 0.14),
      colorScheme.surfaceContainerHighest,
    );
  }
}

/// Reusable product icon widget.
///
/// Use this widget anywhere a product needs to be visually represented.
///
/// The visual style automatically adapts to the current theme.
class ProductIcon extends StatelessWidget {
  const ProductIcon({
    super.key,
    required this.product,
    this.size = 60,
    this.iconSize = 29,
    this.borderRadius = 17,
  });

  final Map<String, dynamic> product;

  final double size;

  final double iconSize;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconData = ProductIconResolver.resolve(product);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ProductIconResolver.backgroundColor(context, iconData),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(iconData.icon, color: iconData.color, size: iconSize),
    );
  }
}

/// Reusable category icon widget.
///
/// Uses the same visual language as ProductIcon and automatically
/// adapts its background for light and dark themes.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.categoryName,
    this.size = 58,
    this.iconSize = 28,
    this.borderRadius = 18,
  });

  final String categoryName;
  final double size;
  final double iconSize;
  final double borderRadius;

  Color _backgroundColor(BuildContext context, ProductIconData iconData) {
    final theme = Theme.of(context);

    if (theme.brightness == Brightness.light) {
      return iconData.backgroundColor;
    }

    return Color.alphaBlend(
      iconData.color.withValues(alpha: 0.14),
      theme.colorScheme.surfaceContainerHighest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = ProductIconResolver.resolveFromText(
      category: categoryName,
    );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _backgroundColor(context, iconData),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(iconData.icon, color: iconData.color, size: iconSize),
    );
  }
}
