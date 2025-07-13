import 'package:easy_localization/easy_localization.dart';

class RecentlyUploadedModel {
  final String image;
  final String titleKey;
  final String time;
  final String overalAllCalorie;
  final String proteinCalorie;
  final String fatsCalorie;
  final String carbsCalorie;

  RecentlyUploadedModel({
    required this.image,
    required this.titleKey,
    required this.time,
    required this.overalAllCalorie,
    required this.proteinCalorie,
    required this.fatsCalorie,
    required this.carbsCalorie,
  });

  String get title => titleKey.tr();
}

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
