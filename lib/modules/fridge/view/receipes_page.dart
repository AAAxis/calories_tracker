import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/modules/fridge/view/meal_detail_view_page.dart';
import 'package:calories_tracker/modules/item_detail/views/item_detail_view.dart';
import 'package:flutter/material.dart';

class ReceipesPage extends StatelessWidget {
  const ReceipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample recipe data
    final List<Map<String, dynamic>> recipes = [
      {
        'name': 'White Sauce Pasta',
        'calories': 358,
        'prepTime': 45,
        'protein': 35,
        'fats': 90,
        'carbs': 78,
      },
      {
        'name': 'White Sauce Pasta',
        'calories': 358,
        'prepTime': 45,
        'protein': 35,
        'fats': 90,
        'carbs': 78,
      },
      {
        'name': 'White Sauce Pasta',
        'calories': 358,
        'prepTime': 45,
        'protein': 35,
        'fats': 90,
        'carbs': 78,
      },
      {
        'name': 'White Sauce Pasta',
        'calories': 358,
        'prepTime': 45,
        'protein': 35,
        'fats': 90,
        'carbs': 78,
      },
      {
        'name': 'White Sauce Pasta',
        'calories': 358,
        'prepTime': 45,
        'protein': 35,
        'fats': 90,
        'carbs': 78,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Wrapper(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/icons/back.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    AppText(
                      'Receipes',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    SizedBox(width: 24),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: recipes.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return _buildRecipeCard(recipe, context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MealDetailView()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/my-ingredients.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [
            // Left Section - Icon
            Image.asset('assets/icons/meal.png', height: 80, width: 80),
            SizedBox(width: 12),
            // Right Section - Recipe Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name and Calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * .65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  recipe['name'],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset('assets/icons/fire.png'),
                                      SizedBox(width: 4),
                                      AppText(
                                        '${recipe['prepTime']} mins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xff8CB9CE).withOpacity(.51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AppText(
                              '${recipe['calories']} kCal',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Preparation Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nutritional Info
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNutritionBar(
                              'Protein',
                              recipe['protein'],
                              Colors.green,
                              context,
                            ),
                            SizedBox(height: 4),
                            _buildNutritionBar(
                              'Fats',
                              recipe['fats'],
                              Colors.red,
                              context,
                            ),
                            SizedBox(height: 4),
                            _buildNutritionBar(
                              'Carbs',
                              recipe['carbs'],
                              Colors.orange,
                              context,
                            ),
                          ],
                        ),
                      ),

                      // Preparation Time
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(
    String label,
    int value,
    Color color,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 5),
        Container(
          height: 4,
          width: MediaQuery.sizeOf(context).width * .14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: AppText(
            '${value}g',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
