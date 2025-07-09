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

class ItemDetailView extends StatelessWidget {
  const ItemDetailView({super.key, required this.data});
  final RecentlyUploadedModel data;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(data.image, width: w, height: h * .55, fit: BoxFit.cover),

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
                    SizedBox(height: 10.h(context)),
                    // Drag handle
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
                            data.title,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                                            filledColor: Colors.black
                                                .withOpacity(0.7),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            'Ingredients',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 20.h(context)),
                          IngredientButtons(),
                          SizedBox(height: 20.h(context)),
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
                  'Nutrition',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset('assets/icons/more.png', height: 40),
                ),
              ],
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
              });
            },
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
                ingredients[index],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
        // Add More Button
        GestureDetector(
          onTap: () {
            context.push('/ingredients');
          },
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
