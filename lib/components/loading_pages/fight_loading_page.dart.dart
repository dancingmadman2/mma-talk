import 'package:flutter/material.dart';
import 'package:mma_talk/components/appbar.dart';

import 'package:mma_talk/components/styles.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FightLoadingPage extends StatelessWidget {
  final String fighterLastNameRed;
  final String fighterLastNameBlue;
  const FightLoadingPage({
    super.key,
    required this.fighterLastNameBlue,
    required this.fighterLastNameRed,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primary,
      appBar: SuckMyBar(
        title: '$fighterLastNameRed  VS  $fighterLastNameBlue',
        title2: 'HEAD-TO-HEAD',
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Skeletonizer(
                child: Container(
                  width: screenWidth / 1.03,
                  decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/fighter.png',
                            height: 360,
                            width: screenWidth / 1.14,
                            fit: BoxFit.cover,
                          )),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Spacer(),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/fighter.png',
                              height: 30,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/fighter.png',
                              height: 30,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        style: nigger,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        style: nigger,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        style: nigger,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        style: nigger,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        style: nigger,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Skeletonizer(
                child: Container(
                  width: screenWidth / 1.03,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white),
                  child: Column(children: [
                    const SizedBox(
                      height: 7.5,
                    ),
                    Text(
                      'WINS BREAKDOWN',
                      style: fighterTitle,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth / 2.1,
                          height: 270,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              labelStyle: fighterTextGrey,
                              labelAlignment: LabelAlignment.center,
                              labelPosition: ChartDataLabelPosition.inside,
                              opposedPosition: true,
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                            ),
                            primaryYAxis: CategoryAxis(
                              visibleMinimum: 0,
                              labelStyle:
                                  const TextStyle(color: Colors.transparent),
                              maximum: 100,
                              minimum: 0,
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                            ),
                            series: <ChartSeries>[
                              BarSeries<String, String>(
                                  color: skeleton,
                                  borderRadius: BorderRadius.circular(4),
                                  dataSource: const <String>[
                                    '        DEC',
                                    '        SUB',
                                    'KO/TKO',
                                  ],
                                  xValueMapper: (String item, _) => item,
                                  yValueMapper: (String item, _) {
                                    // Define different values for each category
                                    if (item == 'KO/TKO') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'KO/TKO'
                                    } else if (item == '        SUB') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'SUB'
                                    } else if (item == '        DEC') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'DEC'
                                    }
                                    return 0; // Default value
                                  },
                                  spacing: 0.4,
                                  width: 0.65,
                                  borderWidth: 1,
                                  borderColor: skeleton,
                                  dataLabelSettings: DataLabelSettings(
                                    alignment: ChartAlignment.near,
                                    offset: const Offset(0, 30),
                                    labelAlignment:
                                        ChartDataLabelAlignment.bottom,
                                    labelPosition:
                                        ChartDataLabelPosition.inside,
                                    isVisible: true,
                                    textStyle: fighterText,
                                  ),
                                  isTrackVisible: true,
                                  trackColor: skeleton),
                            ],
                            plotAreaBorderColor: Colors.transparent,
                          ),
                        ),
                        SizedBox(
                          width: screenWidth / 2.1,
                          height: 270,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              isVisible: true,
                              labelStyle: fighterTextGrey,
                              labelAlignment: LabelAlignment.center,
                              labelPosition: ChartDataLabelPosition.inside,
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                            ),
                            primaryYAxis: CategoryAxis(
                              isInversed: true,
                              visibleMinimum: 0,
                              labelStyle:
                                  const TextStyle(color: Colors.transparent),
                              maximum: 100,
                              minimum: 0,
                              majorTickLines: const MajorTickLines(size: 0),
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                            ),
                            series: <ChartSeries>[
                              BarSeries<String, String>(
                                  color: skeleton,
                                  borderRadius: BorderRadius.circular(4),
                                  dataSource: const <String>[
                                    'DEC',
                                    'SUB',
                                    'KO/TKO',
                                  ],
                                  xValueMapper: (String item, _) => item,
                                  yValueMapper: (String item, _) {
                                    // Define different values for each category
                                    if (item == 'KO/TKO') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'KO/TKO'
                                    } else if (item == 'SUB') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'SUB'
                                    } else if (item == 'DEC') {
                                      return int.parse(
                                        '33',
                                      ); // Set the value for 'DEC'
                                    }
                                    return 0; // Default value
                                  },
                                  spacing: 0.4,
                                  width: 0.65,
                                  borderWidth: 1,
                                  borderColor: skeleton,
                                  dataLabelSettings: DataLabelSettings(
                                    alignment: ChartAlignment.far,
                                    offset: const Offset(0, 30),
                                    labelAlignment:
                                        ChartDataLabelAlignment.bottom,
                                    labelPosition:
                                        ChartDataLabelPosition.inside,
                                    isVisible: true,
                                    textStyle: fighterText,
                                  ),
                                  isTrackVisible: true,
                                  trackColor: skeleton),
                            ],
                            plotAreaBorderColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
