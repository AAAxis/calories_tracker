import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SplineChart extends StatelessWidget {
  final List<ChartData> chartData = [
    ChartData('Jan', 30),
    ChartData('Feb', 45),
    ChartData('Mar', 28),
    ChartData('Apr', 60),
    ChartData('May', 48),
    ChartData('Jun', 75),
    ChartData('Jul', 30),
    ChartData('Aug', 25),
  ];

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: ''),

      legend: Legend(isVisible: false),

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
        majorTickLines: MajorTickLines(size: 0),
        axisLine: AxisLine(
          color: Colors.grey, // X-axis line color
          width: 1,
        ),
        majorGridLines: MajorGridLines(
          color: Colors.grey[300]!,
          dashArray: [5, 5],
        ),

        minimum: 0,
        maximum: 80,
        interval: 20,
        labelFormat: '{value}Kg',
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
      ),

      series: <CartesianSeries>[
        SplineSeries<ChartData, String>(
          color: Colors.black,
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.month,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Monthly Growth',
          markerSettings: MarkerSettings(isVisible: false),
        ),
      ],
    );
  }
}

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}
