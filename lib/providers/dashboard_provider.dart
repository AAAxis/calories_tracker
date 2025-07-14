import 'package:flutter/material.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentPage = 0;
  double _caloriesConsumed = 0.0;
  double _proteinValue = 0.0;
  double _fatsValue = 0.0;
  double _carbsValue = 0.0;
  List<RecentlyUploadedModel> _recentlyUploadedList = [];
  List<Meal> _meals = [];
  bool _isLoading = true;
  String _userName = 'User';
  DateTime? _selectedDate;
  bool _isInitialized = false;

  DashboardProvider() {
    _loadUserName();
    _loadMealsFromStorage();
  }

  // Initialize Firebase-dependent operations
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Wait a bit to ensure Firebase is fully initialized
      await Future.delayed(Duration(milliseconds: 500));
      
      // Reload meals with Firebase support
      await _loadMealsFromStorage();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing DashboardProvider: $e');
    }
  }

  // Getters
  int get currentPage => _currentPage;
  double get caloriesConsumed => _caloriesConsumed;
  double get proteinValue => _proteinValue;
  double get fatsValue => _fatsValue;
  double get carbsValue => _carbsValue;
  List<RecentlyUploadedModel> get recentlyUploadedList => _recentlyUploadedList;
  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  DateTime? get selectedDate => _selectedDate;

  // Methods
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _updateNutritionValues();
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

  Future<void> _loadUserName() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      } else {
        final prefs = await SharedPreferences.getInstance();
        _userName = prefs.getString('user_name') ?? 'User';
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user name: $e');
      _userName = 'User';
      notifyListeners();
    }
  }

  Future<void> _loadMealsFromStorage() async {
    try {
      if (_meals.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      // Load from local storage first
      List<Meal> loadedMeals = await Meal.loadFromLocalStorage();

      // Only try Firebase if we're initialized and user is authenticated
      if (_isInitialized) {
        final user = AuthService.currentUser;
        if (user != null) {
          try {
            print('🔥 Loading meals from Firebase for user: ${user.uid}');
            final querySnapshot = await FirebaseFirestore.instance
                .collection('analyzed_meals')
                .where('userId', isEqualTo: user.uid)
                .orderBy('timestamp', descending: true)
                .get();

            final firebaseMeals = querySnapshot.docs.map((doc) {
              return Meal.fromMap(doc.data(), doc.id);
            }).toList();

            // Merge Firebase meals with local meals, prioritizing Firebase
            final localMealIds = loadedMeals.map((m) => m.id).toSet();
            final newFirebaseMeals = firebaseMeals.where((m) => !localMealIds.contains(m.id)).toList();
            
            _meals = [...newFirebaseMeals, ...loadedMeals];
            
            // Save Firebase meals to local storage for offline access
            for (final meal in newFirebaseMeals) {
              await Meal.addToLocalStorage(meal);
            }
            
            print('✅ Loaded ${_meals.length} meals (${newFirebaseMeals.length} from Firebase)');
          } catch (e) {
            print('❌ Error loading from Firebase: $e, using local storage only');
            _meals = loadedMeals;
          }
        } else {
          // User not authenticated, use local storage only
          _meals = loadedMeals;
        }
      } else {
        // Not initialized yet, use local storage only
        _meals = loadedMeals;
      }

      _updateNutritionValues();
      _updateRecentlyUploadedList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading meals: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    // Preserve analyzing meals during refresh
    final analyzingMeals = _meals.where((meal) => meal.isAnalyzing).toList();
    print('🔄 Refreshing dashboard, preserving ${analyzingMeals.length} analyzing meals');

    await _loadMealsFromStorage();

    // Re-add analyzing meals that weren't in the loaded data
    if (analyzingMeals.isNotEmpty) {
      final loadedMealIds = _meals.map((m) => m.id).toSet();
      final missingAnalyzingMeals = analyzingMeals.where((m) => !loadedMealIds.contains(m.id)).toList();

      if (missingAnalyzingMeals.isNotEmpty) {
        print('🔄 Re-adding ${missingAnalyzingMeals.length} analyzing meals');
        _meals = [..._meals, ...missingAnalyzingMeals];
        _updateNutritionValues();
        _updateRecentlyUploadedList();
        notifyListeners();
      }
    }
  }

  void updateMeals(List<Meal> newMeals) {
    print('🔄 DashboardProvider.updateMeals called with ${newMeals.length} meals');
    print('🔍 Call stack: ${StackTrace.current.toString().split('\n').take(5).join('\n')}');
    final analyzingCount = newMeals.where((meal) => meal.isAnalyzing).length;
    print('🔍 Analyzing meals count: $analyzingCount');
    
    // Debug: Print all meals being set
    for (int i = 0; i < newMeals.length; i++) {
      final meal = newMeals[i];
      print('  [${i}] isAnalyzing: ${meal.isAnalyzing}, id: ${meal.id}, imageUrl: ${meal.imageUrl?.substring(meal.imageUrl!.length - 30) ?? 'null'}, localPath: ${meal.localImagePath?.substring(meal.localImagePath!.length - 30) ?? 'null'}');
    }
    
    _meals = newMeals;
    _updateNutritionValues();
    _updateRecentlyUploadedList();
    print('🔄 Notifying listeners...');
    notifyListeners();
    print('✅ Dashboard state updated');
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      // Delete from local storage
      await Meal.deleteFromLocalStorage(mealId);

      // Delete from Firebase if user is authenticated
      final user = AuthService.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('analyzed_meals')
              .doc(mealId)
              .delete();
          print('✅ Meal deleted from Firebase');
        } catch (e) {
          print('❌ Error deleting from Firebase: $e');
        }
      }

      // Remove from local list
      _meals.removeWhere((meal) => meal.id == mealId);
      _updateNutritionValues();
      _updateRecentlyUploadedList();
      notifyListeners();
    } catch (e) {
      print('Error deleting meal: $e');
    }
  }

  List<Meal> get filteredMeals {
    if (_selectedDate == null) {
      return _meals;
    }

    final startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _meals.where((meal) =>
        meal.timestamp.isAfter(startOfDay) &&
        meal.timestamp.isBefore(endOfDay)
    ).toList();
  }

  void _updateNutritionValues() {
    final mealsToCalculate = _selectedDate == null ? _meals : filteredMeals;
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFats = 0;
    double totalCarbs = 0;

    for (final meal in mealsToCalculate) {
      if (!meal.isAnalyzing && !meal.analysisFailed) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalFats += meal.fat;
        totalCarbs += meal.carbs;
      }
    }

    _caloriesConsumed = totalCalories;
    
    // Calculate progress values (assuming daily targets)
    const double proteinTarget = 90.0;
    const double fatsTarget = 70.0;
    const double carbsTarget = 110.0;

    _proteinValue = totalProtein / proteinTarget;
    _fatsValue = totalFats / fatsTarget;
    _carbsValue = totalCarbs / carbsTarget;

    // Clamp values to 0-1 range
    _proteinValue = _proteinValue.clamp(0.0, 1.0);
    _fatsValue = _fatsValue.clamp(0.0, 1.0);
    _carbsValue = _carbsValue.clamp(0.0, 1.0);
  }

  void _updateRecentlyUploadedList() {
    // Include analyzing meals in the display but exclude failed ones
    final recentMeals = _meals
        .where((meal) => !meal.analysisFailed)  // Only exclude failed meals, keep analyzing ones
        .take(10)
        .toList();

    _recentlyUploadedList = recentMeals.map((meal) {
      return RecentlyUploadedModel(
        mealId: meal.id, // Add meal ID for deletion
        image: meal.imageUrl ?? meal.localImagePath ?? 'assets/images/burger.jpg',
        titleKey: meal.isAnalyzing ? 'Analyzing...' : meal.getDisplayName(),  // Show "Analyzing..." for analyzing meals
        time: _formatTime(meal.timestamp),
        overalAllCalorie: meal.isAnalyzing ? '--' : '${meal.calories.toInt()} kCal',  // Special display for analyzing
        proteinCalorie: meal.isAnalyzing ? '--' : '${meal.protein.toInt()}g',
        fatsCalorie: meal.isAnalyzing ? '--' : '${meal.fat.toInt()}g',
        carbsCalorie: meal.isAnalyzing ? '--' : '${meal.carbs.toInt()}g',
      );
    }).toList();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool hasScansToday() {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return _meals.any((meal) =>
        meal.timestamp.isAfter(startOfToday) &&
        meal.timestamp.isBefore(endOfToday) &&
        !meal.isAnalyzing &&
        !meal.analysisFailed
    );
  }

} 