import 'package:calories_tracker/core/styles/styles.dart';
import 'package:calories_tracker/modules/dashboard/components/bmi_guage_widget.dart';
import 'package:calories_tracker/modules/dashboard/components/spline_chart.dart';
import 'package:flutter/material.dart';
import 'package:calories_tracker/utils/responsive_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:syncfusion_flutter_charts/charts.dart'
    show
        SplineSeries,
        MarkerSettings,
        ChartSeries,
        ChartTitle,
        Legend,
        TooltipBehavior,
        CategoryAxis,
        NumericAxis,
        DataLabelSettings,
        SfCartesianChart,
        CartesianSeries,
        AxisLine,
        MajorGridLines,
        AxisBorderType,
        ColumnSeries,
        ChartAxisLabel,
        MajorTickLines,
        AxisLabelRenderDetails;

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
  int selectedIndex = 0;
  int stepsCountselectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'he';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'stats.title'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading:
            false, // Remove back button since this is a tab
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // WATER INTAKE SECTION
              AppText(
                'stats.water_intake'.tr(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  'dashboard.water_intake'.tr(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                AppText(
                                  '${totalIntake.toStringAsFixed(1)}/${(glassCount * glassVolume).toStringAsFixed(1)} ${'dashboard.litres'.tr()}',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff5A5B5C),
                                  maxLines: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (filledCount > 0) filledCount--;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/Minus.png',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (filledCount < glassCount)
                                            filledCount++;
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/Plus.png',
                                      ),
                                    ),
                                  ],
                                ),
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
                'stats.progress_and_stats'.tr(),
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
                          left: isRtl ? 80.w(context) : 10.w(context),
                          right: isRtl ? 10.w(context) : 80.w(context),
                          child: Text(
                            'dashboard.streaks_count'.tr(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 20.h(context),

                          child: Image.asset(
                            'assets/icons/flame.png',
                            height: 80,
                          ),
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
                          left: 10.w(context),
                          right: 10.w(context),
                          child: Text(
                            'dashboard.you_doing_great'.tr(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
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
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 18,
                        right: 10,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'dashboard.current_weight'.tr(),
                                  style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                'assets/icons/spark.png',
                                height: 35,
                                width: 35,
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
              SizedBox(height: 20),
              AppText(
                'Weight Over Time',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTab('Weekly', 0)),
                  Expanded(child: _buildTab('Monthly', 1)),
                  Expanded(child: _buildTab('Custom', 2)),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * .3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/bggraph.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        child: AppText(
                          'Weight Over Time',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(child: SplineChart()),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              AppText(
                'Calories consumed',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * .3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/bggraph.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: AppText(
                        'Calories consumed',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        tooltipBehavior: TooltipBehavior(enable: true),
                        primaryXAxis: CategoryAxis(
                          majorTickLines: MajorTickLines(size: 0),
                          labelStyle: GoogleFonts.poppins(color: Colors.grey),
                          axisLine: AxisLine(
                            color: Colors.grey, // X-axis line color
                            width: 1,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}Kg',
                          labelStyle: GoogleFonts.poppins(color: Colors.grey),
                          majorTickLines: MajorTickLines(size: 0),
                          axisLine: AxisLine(
                            color: Colors.grey, // X-axis line color
                            width: 1,
                          ),
                          majorGridLines: MajorGridLines(
                            color: Colors.grey[300]!,
                            dashArray: [5, 5],
                          ),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.month,
                            yValueMapper: (ChartData data, _) => data.value,
                            width: 0.4,
                            borderRadius: BorderRadius.circular(8),
                            pointColorMapper: (ChartData data, _) => null,
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.yellow,
                                Colors.orange,
                                Colors.red,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              AppText('Your BMI', fontSize: 14, fontWeight: FontWeight.w600),
              SizedBox(height: 20),
              BmiGaugeWidget(),

              SizedBox(height: 20),
              AppText('Step Count', fontSize: 14, fontWeight: FontWeight.w600),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * .3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/bggraph.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        top: 10,
                        right: 20,
                      ),
                      child: Row(
                        children: [
                          AppText(
                            'Step Count',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          Spacer(),
                          _buildStepCountTab('Daily', 0),
                          _buildStepCountTab('Weekly', 1),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        tooltipBehavior: TooltipBehavior(enable: true),
                        primaryXAxis: CategoryAxis(
                          majorTickLines: MajorTickLines(size: 0),
                          labelStyle: GoogleFonts.poppins(color: Colors.grey),
                          axisLine: AxisLine(
                            color: Colors.grey, // X-axis line color
                            width: 1,
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}Kg',
                          labelStyle: GoogleFonts.poppins(color: Colors.grey),
                          majorTickLines: MajorTickLines(size: 0),
                          axisLine: AxisLine(
                            color: Colors.grey, // X-axis line color
                            width: 1,
                          ),
                          majorGridLines: MajorGridLines(
                            color: Colors.grey[300]!,
                            dashArray: [5, 5],
                          ),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.month,
                            yValueMapper: (ChartData data, _) => data.value,
                            width: 0.4,
                            borderRadius: BorderRadius.circular(8),
                            pointColorMapper: (ChartData data, _) => null,
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xff0099D4), Color(0xffFFCC00)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        if (index == 2) {
          _showDateRangePopup();
        }
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

  // step count tab
  Widget _buildStepCountTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          stepsCountselectedIndex = index;
        });
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              stepsCountselectedIndex == index
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
                  stepsCountselectedIndex == index
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _showDateRangePopup() {
    DateTime? fromDate;
    DateTime? toDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Date Range',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // From Date Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/datepicker.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                fromDate = date;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fromDate != null
                                      ? '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}'
                                      : 'From',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        fromDate != null
                                            ? Colors.black
                                            : Colors.grey[500],
                                  ),
                                ),
                                Image.asset('assets/icons/calendar.png'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // To Date Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/datepicker.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  toDate ?? (fromDate ?? DateTime.now()),
                              firstDate: fromDate ?? DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                toDate = date;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  toDate != null
                                      ? '${toDate!.day}/${toDate!.month}/${toDate!.year}'
                                      : 'To',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        toDate != null
                                            ? Colors.black
                                            : Colors.grey[500],
                                  ),
                                ),
                                Image.asset('assets/icons/calendar.png'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      (fromDate != null && toDate != null)
                          ? () {
                            // Handle the date range selection
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Date range selected: ${fromDate!.day}/${fromDate!.month}/${fromDate!.year} to ${toDate!.day}/${toDate!.month}/${toDate!.year}',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

final List<ChartData> chartData = [
  ChartData('Jan', 30),
  ChartData('Feb', 40),
  ChartData('Mar', 35),
  ChartData('Apr', 60),
  ChartData('May', 42),
  ChartData('Jun', 38),
  ChartData('Jul', 50),
  ChartData('Aug', 33),
];
