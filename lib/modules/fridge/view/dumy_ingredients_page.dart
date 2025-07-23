import 'package:calories_tracker/core/constants/app_colors.dart';
import 'package:calories_tracker/core/constants/calorie_guage.dart';
import 'package:calories_tracker/core/constants/wrapper.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/calorie_tracker_progressbar.dart';
import 'package:calories_tracker/modules/fridge/components/nutrition_goal_row_data.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DummyIngredientsPage extends StatelessWidget {
  const DummyIngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            'assets/icons/ingredients-back.png',
                            height: 40,
                          ),
                        ),
                        Text(
                          'Edit Ingredients',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/icons/delete.png',
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peanut Butter',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
                                          fillPercent: 0.7,
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
                                            '188',
                                            fontSize: 28,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          AppText(
                                            'Ingredient Calories',
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
                                        title: 'Protein',
                                        value: 0.58,
                                        overallValue: '8g',
                                        color: AppColors.greenColor,
                                      ),
                                      CalorieTrackerProgressBar(
                                        title: 'Fats',
                                        value: 0.8,
                                        overallValue: '16g',
                                        color: AppColors.redColor,
                                      ),
                                      CalorieTrackerProgressBar(
                                        title: 'Carbs',
                                        value: 0.48,
                                        overallValue: '7g',
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
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/icons/my-ingredients.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Measurements',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              MeasurementSelector(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        Container(
                          height: 90,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/icons/my-ingredients.png',
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: NutritionGoalsRowData(
                            title: 'How many servings?',
                            controller: TextEditingController(),
                            hintText: '2.5',
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
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
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
  const MeasurementSelector({super.key});

  @override
  State<MeasurementSelector> createState() => _MeasurementSelectorState();
}

class _MeasurementSelectorState extends State<MeasurementSelector> {
  final List<String> measurements = ['tsp.', 'tbsp.', 'Cup', 'Ounce'];
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(measurements.length, (index) {
          final isSelected = selected == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selected = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      isSelected
                          ? 'assets/icons/select-tsp.png'
                          : 'assets/icons/tsp.png',
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
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
            ),
          );
        }),
      ),
    );
  }
}

class ServingsInput extends StatefulWidget {
  const ServingsInput({super.key});

  @override
  State<ServingsInput> createState() => _ServingsInputState();
}

class _ServingsInputState extends State<ServingsInput> {
  final TextEditingController _controller = TextEditingController(text: '2 ½');
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
                    onSubmitted: (_) {
                      setState(() {
                        _editing = false;
                      });
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
