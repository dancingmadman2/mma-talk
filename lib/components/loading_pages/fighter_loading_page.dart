import 'package:flutter/material.dart';

import 'package:mma_talk/components/styles.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../appbar.dart';

class FighterLoadingPage extends StatelessWidget {
  final String fighterName;
  const FighterLoadingPage({super.key, required this.fighterName});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: primary,
        appBar: SuckMyBar(
          title: fighterName,
          title2: ' ',
        ),
        body: SingleChildScrollView(
            child: Skeletonizer(
          child: Center(
              child: Column(children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              width: screenWidth / 1.03,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 60,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/fighter.png',
                              width: 150,
                              height: 130,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 120,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  'ALEXANDER',
                                  style: fighterTitleLight,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  'VOLKANOVSKI',
                                  style: fighterTitle,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: 150,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/fighter.png',
                                        height: 30,
                                        width: 100,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  'WELTERWEIGHT DIVISION',
                                  style: fighterTextSmall,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'KESCININANNESISERTSEVER.COM',
                                    style: fighterTextSmallGrey,
                                  ),
                                  Text(
                                    'KESCININANNESISERTSEVER.COM',
                                    style: fighterTextSmallGrey,
                                  ),
                                  Text(
                                    'KESCININANNESISERTSEVER.COM',
                                    style: fighterTextSmallGrey,
                                  ),
                                  Text(
                                    'KESCININANNESISERTSEVER.COM',
                                    style: fighterTextSmallGrey,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: screenWidth / 1.03,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                const SizedBox(height: 15),
                Text(
                  'STATS & RECORDS',
                  style: fighterTitle,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  '26-2-0(W-L-D)',
                  style: fighterTextRed,
                ),
                SizedBox(
                  width: screenWidth / 1.15,
                  height: 150,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: fighterTextGrey,
                      labelAlignment: LabelAlignment.center,
                      majorTickLines: const MajorTickLines(size: 0),
                      majorGridLines: const MajorGridLines(width: 0),
                      minorGridLines: const MinorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                    ),
                    primaryYAxis: CategoryAxis(
                      visibleMinimum: 0,
                      labelStyle: const TextStyle(color: Colors.transparent),
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
                          spacing: 0.25,
                          width: 0.65,
                          borderWidth: 1,
                          borderColor: skeleton,
                          dataLabelSettings: DataLabelSettings(
                            labelAlignment: ChartDataLabelAlignment.auto,
                            isVisible: true,
                            textStyle: fighterText,
                          ),
                          isTrackVisible: true,
                          trackColor: skeleton),
                    ],
                    plotAreaBorderColor: Colors.transparent,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          'STRIKING ACCURACY',
                          style: fighterTextGrey,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                            width: 75,
                            height: 75,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle)),
                        const SizedBox(
                          height: 60,
                        ),
                        Text(
                          '6.25',
                          style: fighterTextBig,
                        ),
                        Text(
                          'Sig. Strikes Landed \n Per Min',
                          style: fighterTextGrey,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          '1.86',
                          style: fighterTextBig,
                        ),
                        Text(
                          'SIG. STRIKE DEFENSE',
                          style: fighterTextGrey,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Column(
                      children: [
                        Text(
                          'TAKEDOWN ACCURACY',
                          style: fighterTextGrey,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Container(
                            width: 75,
                            height: 75,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            )),
                        const SizedBox(
                          height: 60,
                        ),
                        Text(
                          '1.86',
                          style: fighterTextBig,
                        ),
                        Text(
                          'Takedown Average\n PER 15 MIN',
                          style: fighterTextGrey,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          '69%',
                          style: fighterTextBig,
                        ),
                        Text(
                          'Takedown Defense',
                          style: fighterTextGrey,
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
              ]),
            ),
          ])),
        )));
  }
}
