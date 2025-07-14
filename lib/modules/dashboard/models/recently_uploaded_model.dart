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

// Sample data for testing (when no real data is available)
List<RecentlyUploadedModel> recentlyUploadedList = [
  RecentlyUploadedModel(
    image: 'assets/images/burger.jpg',
    titleKey: 'food_items.burger',
    time: '14:53 PM',
    overalAllCalorie: '157 kCal',
    proteinCalorie: '56g',
    fatsCalorie: '84g',
    carbsCalorie: '85g',
  ),
  RecentlyUploadedModel(
    image: 'assets/images/pizza.jpg',
    titleKey: 'food_items.pizza',
    time: '20:25 PM',
    overalAllCalorie: '365 kCal',
    proteinCalorie: '39g',
    fatsCalorie: '45g',
    carbsCalorie: '40g',
  ),
  RecentlyUploadedModel(
    image: 'assets/images/white_sauce_pasta.png',
    titleKey: 'food_items.white_sauce_pasta',
    time: '10:20 PM',
    overalAllCalorie: '358 kCal',
    proteinCalorie: '80g',
    fatsCalorie: '120g',
    carbsCalorie: '35g',
  ),
];
