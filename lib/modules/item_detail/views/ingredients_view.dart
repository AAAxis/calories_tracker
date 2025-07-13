import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/routes/app_routes.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

// Ingredient model
class Ingredient {
  final String name;
  final int kcal;
  final String serving;

  Ingredient({required this.name, required this.kcal, required this.serving});
}

// Dummy ingredient data - will be initialized inside widget
List<Ingredient> getDummyIngredients() {
  return [
    Ingredient(name: 'ingredients.ingredients_list.plain_yogurt'.tr(), kcal: 10, serving: 'ingredients.serving_units.tbsp'.tr()),
    Ingredient(name: 'ingredients.ingredients_list.peanut_butter'.tr(), kcal: 106, serving: 'ingredients.serving_units.tbsp'.tr()),
    Ingredient(name: 'ingredients.ingredients_list.egg'.tr(), kcal: 74, serving: 'ingredients.serving_units.large'.tr()),
    Ingredient(name: 'ingredients.ingredients_list.avocado'.tr(), kcal: 10, serving: 'ingredients.serving_units.serving'.tr()),
    Ingredient(name: 'ingredients.ingredients_list.butter'.tr(), kcal: 810, serving: 'ingredients.serving_units.stick'.tr()),
    Ingredient(name: 'ingredients.ingredients_list.spinach'.tr(), kcal: 455, serving: 'ingredients.serving_units.cup'.tr()),
  ];
}

class IngredientsView extends StatelessWidget {
  const IngredientsView({super.key});

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
              SearchField(w: w),
              SizedBox(height: 40.h(context)),
              Text(
                'ingredients.suggestions'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    final ingredients = getDummyIngredients();
                    return GestureDetector(
                      onTap: () {
                        context.push('/edit-ingredients', extra: ingredients[index].name);
                      },
                      child: Container(
                        width: w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/icons/suggestion-glass.png',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Text(
                                        ingredients[index].name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/icons/flame-suggestions.png',
                                          height: 25,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${ingredients[index].kcal}kCal',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '\u2022',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black.withOpacity(
                                              .57,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          ingredients[index].serving,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black.withOpacity(
                                              .57,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Image.asset('assets/icons/Add.png', height: 34),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) {
                    return SizedBox(height: 10.h(context));
                  },
                  itemCount: getDummyIngredients().length,
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
