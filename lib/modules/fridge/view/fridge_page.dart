import 'package:calories_tracker/core/custom_widgets/primary_button.dart';
import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/fridge/components/nutrition_goal_row_data.dart';
import 'package:calories_tracker/modules/fridge/view/receipes_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  int selectedIndex = 0;
  int cookingTimeSelectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppText(
              'My Fridge',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * .03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  // height: MediaQuery.sizeOf(context).height * .1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/my-ingredients.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Use only my ingredients ',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [_buildTab('Yes', 0), _buildTab('No', 1)],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                AppText(
                  'Do You want something specific',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * .1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/my-ingredients.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: TextFormField(
                    maxLines: 10,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter to add something specific',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffa4a4a4),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * .2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/goal.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Nutritional Goals',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),

                        NutritionGoalsRowData(
                          title: 'Serving Protein',
                          controller: TextEditingController(),
                          hintText: '2.5',
                        ),
                        SizedBox(height: 10),
                        NutritionGoalsRowData(
                          title: 'Serving Calories',
                          controller: TextEditingController(),
                          hintText: '2.5',
                        ),
                        SizedBox(height: 10),
                        NutritionGoalsRowData(
                          title: 'How Many Servings',
                          controller: TextEditingController(),
                          hintText: '2.5',
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * .2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/goal.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Estimated Cooking Time ',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCookingTimeTab('Slow', 0),
                            _buildCookingTimeTab('Medium', 1),
                            _buildCookingTimeTab('Fast', 2),
                          ],
                        ),
                        Row(
                          children: [
                            Text(String.fromCharCode(0x2022)),
                            AppText(
                              'Slow its above 1h clock',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(String.fromCharCode(0x2022)),
                            AppText(
                              'Medium 30-60 min',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(String.fromCharCode(0x2022)),
                            AppText(
                              'Fast max 30 min',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * .03),
                Center(
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * .8,
                    child: PrimaryButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceipesPage(),
                          ),
                        );
                      },
                      label: 'Create Recipe',
                      backgroundColor: Color(0xff000000),
                      textColor: Colors.white,
                      borderRadius: 18,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        // Show date range popup when Custom tab is selected
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              selectedIndex == index
                  ? 'assets/icons/filled-tab.png'
                  : 'assets/icons/unselect-tab.png',
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selectedIndex == index ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCookingTimeTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          cookingTimeSelectedIndex = index;
        });

        // Show date range popup when Custom tab is selected
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              cookingTimeSelectedIndex == index
                  ? 'assets/icons/filled-tab.png'
                  : 'assets/icons/unselect-tab.png',
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  cookingTimeSelectedIndex == index
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
