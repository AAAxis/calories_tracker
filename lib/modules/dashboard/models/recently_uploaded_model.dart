import 'package:easy_localization/easy_localization.dart';

class RecentlyUploadedModel {
  final String? mealId; // Add meal ID for deletion
  final String image;
  final String titleKey;
  final String time;
  final String overalAllCalorie;
  final String proteinCalorie;
  final String fatsCalorie;
  final String carbsCalorie;

  RecentlyUploadedModel({
    this.mealId,
    required this.image,
    required this.titleKey,
    required this.time,
    required this.overalAllCalorie,
    required this.proteinCalorie,
    required this.fatsCalorie,
    required this.carbsCalorie,
  });

  String get title => titleKey.tr();
  
  // Check if image is a network image (starts with http/https)
  bool get isNetworkImage => image.startsWith('http://') || image.startsWith('https://');
  
  // Check if image is a local file path
  bool get isLocalFile => image.startsWith('/') || image.contains('\\');
  
  // Check if image is an asset
  bool get isAssetImage => !isNetworkImage && !isLocalFile;

  // Get display title (handle both translation keys and direct strings)
  String get displayTitle {
    if (titleKey.startsWith('food_items.') || titleKey.startsWith('dashboard.')) {
      return titleKey.tr();
    }
    return titleKey; // Return as-is if it's already a direct string
  }
}
