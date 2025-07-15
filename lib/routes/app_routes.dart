import 'package:calories_tracker/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:calories_tracker/modules/dashboard/views/dashboard_view.dart';
import 'package:calories_tracker/modules/item_detail/views/edit_ingredients_view.dart';
import 'package:calories_tracker/modules/item_detail/views/ingredients_view.dart';
import 'package:calories_tracker/modules/item_detail/views/item_detail_view.dart';
import 'package:calories_tracker/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String bottomNav = '/';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String itemDetail = '/item-detail';
  static const String ingredients = '/ingredients';
  static const String editIngredients = '/edit-ingredients';
  
  static Map<String, WidgetBuilder> get routes => {
    bottomNav: (context) => const BottomNavView(),
    dashboard: (context) => const DashboardView(),
    profile: (context) => const ProfileView(),
    ingredients: (context) => const IngredientsView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case itemDetail:
        final meal = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (context) => ItemDetailView(meal: meal),
        );
      case editIngredients:
        final ingredient = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (context) => EditIngredientsView(ingredient: ingredient),
        );
      default:
        return null;
    }
  }
}
