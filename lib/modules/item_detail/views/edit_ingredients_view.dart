import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/features/models/meal_model.dart';
import 'package:calories_tracker/core/services/nutrition_database_service.dart';
import 'package:calories_tracker/core/services/translation_service.dart';

class EditIngredientsView extends StatefulWidget {
  const EditIngredientsView({super.key, required this.ingredient});
  final Ingredient ingredient;

  @override
  State<EditIngredientsView> createState() => _EditIngredientsViewState();
}

class _EditIngredientsViewState extends State<EditIngredientsView> {
  late double _grams;
  late double _servings;
  late int _selectedMeasurement;

  @override
  void initState() {
    super.initState();
    _grams = widget.ingredient.grams;
    _servings = 1.0; // Default servings
    _selectedMeasurement = 1; // Default to tbsp
  }

  Ingredient _createUpdatedIngredient() {
    // Calculate nutrition based on new grams
    final totalGrams = _grams * _servings;
    final nutrition = NutritionDatabaseService.calculateNutrition(widget.ingredient.name, totalGrams);
    
    final updatedIngredient = Ingredient(
      name: widget.ingredient.name,
      grams: totalGrams,
      calories: nutrition['calories'] ?? 0,
      protein: nutrition['proteins'] ?? 0,
      carbs: nutrition['carbs'] ?? 0,
      fat: nutrition['fats'] ?? 0,
    );
    
    return updatedIngredient;
  }

  /// Get translated ingredient name
  Future<String> _getTranslatedIngredientName() async {
    try {
      final locale = context.locale.languageCode;
      
      // If already in English, no need to translate
      if (locale == 'en') {
        return widget.ingredient.name;
      }
      
      // Translate using TranslationService
      final translatedName = await TranslationService.translateIngredient(
        widget.ingredient.name,
        locale,
      );
      
      return translatedName;
    } catch (e) {
      print('❌ Error translating ingredient name: $e');
      return widget.ingredient.name; // Fallback to original
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = widget.ingredient;
    final currentIngredient = _createUpdatedIngredient(); // Cache the calculated ingredient
    return Scaffold(
      body: SingleChildScrollView(
        child: Wrapper(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Image.asset(
                            'assets/icons/ingredients-back.png',
                            height: 40,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'edit_ingredients.edit_ingredients'.tr(),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40), // Placeholder for alignment
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getTranslatedIngredientName(),
                          builder: (context, snapshot) {
                            final translatedName = snapshot.data ?? widget.ingredient.name;
                            return Text(
                              translatedName,
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(_grams * _servings).toStringAsFixed(0)}g, ${currentIngredient.calories.toStringAsFixed(0)} kcal',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 40.h(context)),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.7),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff999999).withOpacity(.25),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Center(
                                      child: CustomPaint(
                                        size: const Size(300, 160),
                                        painter: CalorieGaugePainter(
                                          fillPercent: (currentIngredient.calories / 400).clamp(0.0, 1.0),
                                          segments: 22,
                                          filledColor: Colors.black.withOpacity(
                                            0.7,
                                          ),
                                          unfilledColor: Color(
                                            0xff525151,
                                          ).withOpacity(.28),
                                          segmentHeight: 60.0,
                                          topWidth: 14.0,
                                          bottomWidth: 10.0,
                                          cornerRadius: 7.0,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10.h(context),
                                      child: Column(
                                        children: [
                                          AppText(
                                            '${currentIngredient.calories.toStringAsFixed(0)}',
                                            fontSize: 28,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          AppText(
                                            'edit_ingredients.ingredient_calories'.tr(),
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h(context)),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w(context),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CalorieTrackerProgressBar(
                                        title: 'common.protein'.tr(),
                                        value: (currentIngredient.protein / 90).clamp(0.0, 1.0),
                                        overallValue: '${currentIngredient.protein.toStringAsFixed(0)}g',
                                        color: AppColors.greenColor,
                                      ),
                                      CalorieTrackerProgressBar(
                                        title: 'common.fats'.tr(),
                                        value: (currentIngredient.fat / 70).clamp(0.0, 1.0),
                                        overallValue: '${currentIngredient.fat.toStringAsFixed(0)}g',
                                        color: AppColors.redColor,
                                      ),
                                      CalorieTrackerProgressBar(
                                        title: 'common.carbs'.tr(),
                                        value: (currentIngredient.carbs / 110).clamp(0.0, 1.0),
                                        overallValue: '${currentIngredient.carbs.toStringAsFixed(0)}g',
                                        color: AppColors.yellowColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h(context)),
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'edit_ingredients.measurements'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),
                              MeasurementSelector(
                                onSelectionChanged: (index) {
                                  setState(() {
                                    _selectedMeasurement = index;
                                    // Update grams based on measurement
                                    switch (index) {
                                      case 0: _grams = 5; break;  // tsp
                                      case 1: _grams = 15; break; // tbsp
                                      case 2: _grams = 240; break; // cup
                                      case 3: _grams = 28; break; // ounce
                                      default: _grams = 100;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'edit_ingredients.number_of_servings'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 12),
                              ServingsInput(
                                onServingsChanged: (servings) {
                                  setState(() {
                                    _servings = servings;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 56.h(context),
                      child: ElevatedButton(
                        onPressed: () {
                          final updatedIngredient = _createUpdatedIngredient();
                          Navigator.pop(context, updatedIngredient);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'edit_ingredients.add_ingredient'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MeasurementSelector extends StatefulWidget {
  const MeasurementSelector({super.key, required this.onSelectionChanged});
  final Function(int) onSelectionChanged;

  @override
  State<MeasurementSelector> createState() => _MeasurementSelectorState();
}

class _MeasurementSelectorState extends State<MeasurementSelector> {
  int selected = 1;

  List<String> getMeasurements() {
    return [
      'edit_ingredients.measurement_units.tsp'.tr(),
      'edit_ingredients.measurement_units.tbsp'.tr(),
      'edit_ingredients.measurement_units.cup'.tr(),
      'edit_ingredients.measurement_units.ounce'.tr()
    ];
  }

  @override
  Widget build(BuildContext context) {
    final measurements = getMeasurements();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(measurements.length, (index) {
          final isSelected = selected == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selected = index;
                });
                widget.onSelectionChanged(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  measurements[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ServingsInput extends StatefulWidget {
  const ServingsInput({super.key, required this.onServingsChanged});
  final Function(double) onServingsChanged;

  @override
  State<ServingsInput> createState() => _ServingsInputState();
}

class _ServingsInputState extends State<ServingsInput> {
  final TextEditingController _controller = TextEditingController(text: '1');
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _editing = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editing
                ? SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _editing = false;
                      });
                      final servings = double.tryParse(value) ?? 1.0;
                      widget.onServingsChanged(servings);
                    },
                  ),
                )
                : Text(
                  _controller.text,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
            SizedBox(width: 8),
            Icon(Icons.edit, size: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
