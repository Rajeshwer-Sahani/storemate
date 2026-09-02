import 'package:storemate/features/store/data/module/store_model.dart';

class ProfileDataModel {
  const ProfileDataModel({
    required this.fullName,
    required this.email,
    required this.isEmailVerified,
    required this.store,
    required this.billCount,
    required this.customerCount,
    required this.totalSales,
  });

  final String fullName;
  final String email;
  final bool isEmailVerified;

  final StoreModel store;

  final int billCount;
  final int customerCount;
  final double totalSales;

  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'SM';
    }

    if (words.length == 1) {
      final word = words.first;

      if (word.length == 1) {
        return word.toUpperCase();
      }

      return word.substring(0, 2).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  String get displayName {
    if (fullName.trim().isEmpty) {
      return 'Store Owner';
    }

    return fullName.trim();
  }
}