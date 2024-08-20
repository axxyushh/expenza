import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary; // Corrected typo here
  final int startMonth;
  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
  });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];
  
  @override
  void initState() {
    // TODO: implement initState
     WidgetsBinding.instance.addPostFrameCallback((timestamop) => scrollToEnd);
  }

  // Initialize bar data
  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length,
            (index) => IndividualBar(x: index, y: widget.monthlySummary[index]));
  }

  //Calculate the upper limit of the bar
  double calculateMax(){
    double max = 500;
    widget.monthlySummary.sort();
    max = widget.monthlySummary.last * 1.05;
    if(max<500){
      return 500;
    }
    return max;
  }

  // scroll controller to scroll throught the end.
  final ScrollController _scrollController = ScrollController();

  void scrollToEnd(){
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn, 
    );
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    //bar dimension sizes
    double barWidth = 20;
    double spaceBetweenBars = 15;


    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData( // Modified this part
                show: true,
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: getBottomTitles, // Pass the function reference
                    reservedSize: 24,

                  ),
                ),
              ),
              barGroups: barData.map((data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                      toY: data.y,
                      width: barWidth,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade800,
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: calculateMax(),
                        color: Colors.white
                      ),
                  ),
                ],
              ))
                  .toList(),
              alignment: BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }

  // B O T T O M - T I T L E S
  Widget getBottomTitles(double value, TitleMeta meta) {
    const textStyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;

    // Calculate the actual month index based on startMonth
    int monthIndex = (value.toInt() + widget.startMonth - 1) % 12;

    switch (monthIndex) {
      case 0:
        text = 'J';
        break;
      case 1:
        text = 'F';
        break;
      case 2:
        text = 'M';
        break;
      case 3:
        text = 'A';
        break;
      case 4:
        text = 'M';
        break;
      case 5:
        text = 'J';
        break;
      case 6:
        text = 'J';
        break;
      case 7:
        text = 'A';
        break;
      case 8:
        text = 'S';
        break;
      case 9:
        text = 'O';
        break;
      case 10:
        text = 'N';
        break;
      case 11:
        text = 'D';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      child: Text(
        text,
        style: textStyle,
      ),
      axisSide: meta.axisSide,
    );
  }
}