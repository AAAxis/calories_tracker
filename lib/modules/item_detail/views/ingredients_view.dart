import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/nutrition_database_service.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key, this.initialIngredients});
  final List<Ingredient>? initialIngredients;

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  late List<Ingredient> _ingredients;
  List<String> _allIngredientNames = [];
  String? _selectedIngredientName;
  double _selectedGrams = 100;

  @override
  void initState() {
    super.initState();
    _ingredients = widget.initialIngredients ?? <Ingredient>[];
    NutritionDatabaseService.initialize().then((_) {
      setState(() {
        _allIngredientNames = NutritionDatabaseService.getAllIngredients();
      });
    });
  }

  void _addIngredientFromSuggestion(String name) {
    final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
    final ingredient = Ingredient(
      name: name,
      grams: 100,
      calories: nutrition['calories'] ?? 0,
      protein: nutrition['proteins'] ?? 0,
      carbs: nutrition['carbs'] ?? 0,
      fat: nutrition['fats'] ?? 0,
    );
    setState(() {
      _ingredients.add(ingredient);
    });
  }

  void _onSuggestionTap(String name) async {
    final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
    final ingredient = Ingredient(
      name: name,
      grams: 100,
      calories: nutrition['calories'] ?? 0,
      protein: nutrition['proteins'] ?? 0,
      carbs: nutrition['carbs'] ?? 0,
      fat: nutrition['fats'] ?? 0,
    );
    final editedIngredient = await context.push('/edit-ingredients', extra: ingredient);
    if (editedIngredient is Ingredient) {
      Navigator.pop(context, editedIngredient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Wrapper(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackActions(),
              SizedBox(height: 20.h(context)),
              Text(
                'ingredients.suggestions'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              // Suggestions list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    final name = _allIngredientNames[index];
                    final nutrition = NutritionDatabaseService.calculateNutrition(name, 100);
                    return GestureDetector(
                      onTap: () => _onSuggestionTap(name),
                      child: Container(
                        width: w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/suggestion-glass.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text('${nutrition['calories']?.toStringAsFixed(0) ?? '--'} kcal, 100g'),
                          trailing: Icon(Icons.add, color: Colors.black),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemCount: _allIngredientNames.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.w});

  final double w;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 10),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(Icons.search, color: Color(0xff999999)),
          ),
          border: InputBorder.none,
          hintText: 'ingredients.search_hint'.tr(),
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xff999999),
          ),
        ),
      ),
    );
  }
}

class BackActions extends StatelessWidget {
  const BackActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Image.asset('assets/icons/ingredients-back.png', height: 50),
          ),
          Text(
            'ingredients.add_ingredients'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}
