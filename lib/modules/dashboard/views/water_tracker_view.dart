import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/step_progress_circle.dart';
import 'package:flutter/material.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  static const int glassCount = 7;
  static const double glassVolume = 0.2; // litres per glass
  int filledCount = 0;

  double get totalIntake => filledCount * glassVolume;

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Stats',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false, // Remove back button since this is a tab
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // ACTIVITY SECTION
              AppText(
                'Activity',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 10),
              StepProgressCircle(
                steps: 3845,
                calories: 3451,
                distance: 1.5,
                percent: 0.22,
              ),
              SizedBox(height: 20),
              
              // WATER INTAKE SECTION
              AppText(
                'Water Intake',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/water_intake.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'dashboard.water_intake'.tr(),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              AppText(
                                '${totalIntake.toStringAsFixed(1)}/${(glassCount * glassVolume).toStringAsFixed(1)} ${'dashboard.litres'.tr()}',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff5A5B5C),
                              ),
                            ],
                          ),
                          Container(
                            height: 35,
                            width: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/icons/gear.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                                left: 10,
                                right: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (filledCount > 0) filledCount--;
                                      });
                                    },
                                    child: Image.asset('assets/icons/Minus.png'),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (filledCount < glassCount) filledCount++;
                                      });
                                    },
                                    child: Image.asset('assets/icons/Plus.png'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          glassCount,
                          (index) => Image.asset(
                            index < filledCount
                                ? 'assets/icons/fill-water.png'
                                : 'assets/icons/water.png',
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h(context)),
              
              // PROGRESS & STATS SECTION
              AppText(
                'Progress & Stats',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 170.w(context),
                    height: 145.h(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/streak.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 10.h(context),
                          left: isRtl ? 110.w(context) : 20.w(context),
                          child: Text(
                            'dashboard.streaks_count'.tr(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20.h(context),

                          child: Image.asset('assets/icons/flame.png', height: 80),
                        ),
                        Positioned(
                          top: 71.h(context),

                          child: Text(
                            '29',
                            style: GoogleFonts.libreBodoni(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 110.h(context),

                          child: Text(
                            'dashboard.you_doing_great'.tr(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),

                  //
                  Container(
                    width: 170.w(context),
                    height: 145.h(context),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/streak.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, left: 18, right: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'dashboard.current_weight'.tr(),
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Image.asset(
                                'assets/icons/spark.png',
                                height: 40,
                                width: 40,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h(context)),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '90.22',
                              // style: GoogleFonts.libreBodoni(

                              style: GoogleFonts.libreBodoni(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                WidgetSpan(child: SizedBox(width: 4)),
                                TextSpan(
                                  text: 'dashboard.kg'.tr(),
                                  style: GoogleFonts.libreBodoni(
                                    color: Color(0xff7a7a7a),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h(context)),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/downward.png',
                                height: 20,
                                width: 20,
                              ),
                              Text(
                                '1.2${'dashboard.kg'.tr()}(-1.68%)',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
