import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/custom_widgets/primary_button.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/fridge/view/dumy_ingredients_page.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';

class MealDetailView extends StatelessWidget {
  const MealDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Column(
        children: [
          Wrapper(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Image.asset(
                              'assets/icons/back.png',
                              height: 40,
                            ),
                          ),
                          Text(
                            'Meal',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              'assets/icons/more.png',
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h(context)),

                      // Drag handle
                      Text(
                        'White Sauce Pasta',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 15.h(context)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: CustomPaint(
                                      size: const Size(300, 150),
                                      painter: CalorieGaugePainter(
                                        fillPercent: .88,
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
                                          '1721',
                                          fontSize: 28,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        AppText(
                                          'Meal Calories',
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h(context)),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w(context),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CalorieTrackerProgressBar(
                                      title: 'Protein',
                                      value: 0.78,
                                      overallValue: '78/90g',
                                      color: AppColors.greenColor,
                                    ),
                                    CalorieTrackerProgressBar(
                                      title: 'Fats',
                                      value: 0.5,
                                      overallValue: '45/70g',
                                      color: AppColors.redColor,
                                    ),
                                    CalorieTrackerProgressBar(
                                      title: 'Carbs',
                                      value: 0.78,
                                      overallValue: '78/110g',
                                      color: AppColors.yellowColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Add your content here
                      SizedBox(height: 20.h(context)),
                      Text(
                        'Ingredients list for recipe',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 20.h(context)),
                      IngredientButtons(),
                      SizedBox(height: 20.h(context)),
                      AppText(
                        'The recipe step by step',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      SizedBox(height: 20.h(context)),
                      ReadMoreText(
                        '''1. Prepare the Patties:
In a bowl, season the ground beef with salt and pepper. Divide it into two equal portions and shape them into patties. Make them slightly larger than the buns since they will shrink while cooking.
                        
2. Cook the Patties:
 Heat a grill or skillet over medium-high heat. Cook the patties for about 4-5 minutes on one side. Flip them over and place a slice of cheddar cheese on each patty. Cook for another 4-5 minutes until the cheese is melted and the patties are cooked to your desired doneness.
                        
3. Toast the Buns:
 While the patties are cooking, slice the hamburger buns in half and toast them on the grill or in a toaster until golden brown.
                        
4. Assemble the Burger:
On the bottom half of each bun, place a lettuce leaf, followed by a cooked patty with melted cheese. Add tomato slices and pickles on top. Spread ketchup and mustard to taste, then cover with the top half of the bun.
                        
5. Serve:
Serve your delicious double cheese burgers with a side of fries or your favorite chips. Enjoy!''',
                        trimMode: TrimMode.Line,
                        trimLines: 5,
                        colorClickableText: Colors.black,
                        trimCollapsedText: 'See More',

                        trimExpandedText: 'See Less',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xff363636),
                          fontWeight: FontWeight.w300,
                        ),
                        lessStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        moreStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h(context)),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * .8,
                          child: PrimaryButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ReceipesPage(),
                              //   ),
                              // );
                            },
                            label: 'Log Deal',

                            backgroundColor: Color(0xff000000),
                            textColor: Colors.white,
                            borderRadius: 18,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

class IngredientButtons extends StatefulWidget {
  const IngredientButtons({super.key});
  @override
  State<IngredientButtons> createState() => _IngredientButtonsState();
}

class _IngredientButtonsState extends State<IngredientButtons> {
  final List<String> ingredients = [
    'Buns',
    'Cheese',
    'Tomato',
    'Beef',
    'Onion',
    'Lettuce',
    'Pickles',
    'Mustard',
    'Ketchup',
  ];
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...List.generate(ingredients.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DummyIngredientsPage(),
                  ),
                );
              });
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: AssetImage('assets/icons/ingredients-wrap.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  ingredients[index],
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
        // Add More Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DummyIngredientsPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Add more',
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
    );
  }
}
