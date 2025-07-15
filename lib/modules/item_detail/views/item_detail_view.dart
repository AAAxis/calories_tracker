import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/dashboard/models/recently_uploaded_model.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:calories_tracker/features/models/meal_model.dart';

class ItemDetailView extends StatefulWidget {
  const ItemDetailView({super.key, required this.meal});
  final Meal meal;

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  late List<String> _ingredients;
  String? _editedMealName;

  @override
  void initState() {
    super.initState();
    // Use meal.ingredients if available, fallback to empty list
    _ingredients = (widget.meal.ingredients is List<String>)
        ? List<String>.from(widget.meal.ingredients)
        : (widget.meal.detailedIngredients != null && widget.meal.detailedIngredients is List)
            ? List<String>.from(widget.meal.detailedIngredients!.map((e) => e.name))
            : <String>[];
  }

  void _deleteIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _deleteIngredientWithDialog(int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Ingredient'),
        content: Text('Are you sure you want to remove "${_ingredients[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  Future<void> _showRenameMealDialog() async {
    final controller = TextEditingController(text: _editedMealName ?? widget.meal.getDisplayName());
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Meal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter new meal name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _editedMealName = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal renamed to "$result"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              ? (meal.imageUrl!.startsWith('http')
                  ? Image.network(meal.imageUrl!, width: w, height: h * .55, fit: BoxFit.cover)
                  : Image.asset(meal.imageUrl!, width: w, height: h * .55, fit: BoxFit.cover))
              : Container(width: w, height: h * .55, color: Colors.grey[200]),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: .85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xff343434),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(
                            _editedMealName ?? meal.getDisplayName(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xff999999).withOpacity(.25),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: CustomPaint(
                                          size: const Size(300, 150),
                                          painter: CalorieGaugePainter(
                                            fillPercent: (meal.calories / 2000).clamp(0.0, 1.0),
                                            segments: 22,
                                            filledColor: Colors.black.withOpacity(0.7),
                                            unfilledColor: Color(0xff525151).withOpacity(.28),
                                            segmentHeight: 60.0,
                                            topWidth: 14.0,
                                            bottomWidth: 10.0,
                                            cornerRadius: 7.0,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: Column(
                                          children: [
                                            AppText(
                                              meal.calories.toInt().toString(),
                                              fontSize: 28,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            AppText(
                                              'item_detail.meal_calories'.tr(),
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CalorieTrackerProgressBar(
                                          title: 'common.protein'.tr(),
                                          value: (meal.protein / 90).clamp(0.0, 1.0),
                                          overallValue: '${meal.protein.toInt()}/90g',
                                          color: AppColors.greenColor,
                                        ),
                                        CalorieTrackerProgressBar(
                                          title: 'common.fats'.tr(),
                                          value: (meal.fat / 70).clamp(0.0, 1.0),
                                          overallValue: '${meal.fat.toInt()}/70g',
                                          color: AppColors.redColor,
                                        ),
                                        CalorieTrackerProgressBar(
                                          title: 'common.carbs'.tr(),
                                          value: (meal.carbs / 110).clamp(0.0, 1.0),
                                          overallValue: '${meal.carbs.toInt()}/110g',
                                          color: AppColors.yellowColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'item_detail.ingredients'.tr(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ...List.generate(_ingredients.length, (index) {
                                return GestureDetector(
                                  onLongPress: () => _deleteIngredientWithDialog(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(.25),
                                          blurRadius: 4,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _ingredients[index],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // Add More Chip
                              GestureDetector(
                                onTap: () {
                                  context.push('/ingredients', extra: _ingredients);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.15),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add More',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset('assets/icons/back.png', height: 40),
                ),
                Text(
                  'item_detail.nutrition'.tr(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Image.asset('assets/icons/more.png', height: 40),
                  onSelected: (value) {
                    if (value == 'favorite') {
                      // TODO: Implement add to favorites logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to favorites!')),
                      );
                    } else if (value == 'edit') {
                      _showRenameMealDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Add to favorites'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black),
                          SizedBox(width: 8),
                          Text('Edit meal'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
