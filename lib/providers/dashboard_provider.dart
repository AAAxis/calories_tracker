import 'package:flutter/material.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentPage = 0;
  double _caloriesConsumed = 1721.0;
  double _proteinValue = 0.78;
  double _fatsValue = 0.5;
  double _carbsValue = 0.78;
  List<RecentlyUploadedModel> _recentlyUploadedList = [];

  DashboardProvider() {
    // Initialize with sample data
    _recentlyUploadedList = [
      RecentlyUploadedModel(
        image: 'assets/images/burger.jpg',
        title: 'Burger',
        time: '14:53 PM',
        overalAllCalorie: '157 kCal',
        proteinCalorie: '56g',
        fatsCalorie: '84g',
        carbsCalorie: '85g',
      ),
      RecentlyUploadedModel(
        image: 'assets/images/pizza.jpg',
        title: 'Pizza',
        time: '20:25 PM',
        overalAllCalorie: '365 kCal',
        proteinCalorie: '39g',
        fatsCalorie: '45g',
        carbsCalorie: '40g',
      ),
      RecentlyUploadedModel(
        image: 'assets/images/white_sauce_pasta.png',
        title: 'White Sauce Pasta',
        time: '10:20 PM',
        overalAllCalorie: '358 kCal',
        proteinCalorie: '80g',
        fatsCalorie: '120g',
        carbsCalorie: '35g',
      ),
    ];
  }

  // Getters
  int get currentPage => _currentPage;
  double get caloriesConsumed => _caloriesConsumed;
  double get proteinValue => _proteinValue;
  double get fatsValue => _fatsValue;
  double get carbsValue => _carbsValue;
  List<RecentlyUploadedModel> get recentlyUploadedList => _recentlyUploadedList;

  // Methods
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void updateCaloriesConsumed(double calories) {
    _caloriesConsumed = calories;
    notifyListeners();
  }

  void updateNutritionValues({
    double? protein,
    double? fats,
    double? carbs,
  }) {
    if (protein != null) _proteinValue = protein;
    if (fats != null) _fatsValue = fats;
    if (carbs != null) _carbsValue = carbs;
    notifyListeners();
  }

  void addRecentlyUploaded(RecentlyUploadedModel item) {
    _recentlyUploadedList.insert(0, item);
    notifyListeners();
  }

  void removeRecentlyUploaded(int index) {
    if (index >= 0 && index < _recentlyUploadedList.length) {
      _recentlyUploadedList.removeAt(index);
      notifyListeners();
    }
  }
} 