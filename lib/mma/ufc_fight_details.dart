import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import 'package:syncfusion_flutter_charts/charts.dart';

import '../components/appbar.dart';

import '../components/background.dart';
import '../components/loading_pages/fight_loading_page.dart.dart';

import '../components/styles.dart';

class FightDetails extends StatefulWidget {
  const FightDetails(
      {super.key,
      required this.fighterRedName,
      required this.fighterBlueName,
      required this.fighterRedOdd,
      required this.fighterBlueOdd,
      required this.fightWeightclass,
      required this.fighterRedLastName,
      required this.fighterBlueLastName,
      required this.fighterRedBodyshot,
      required this.fighterBlueBodyshot,
      required this.fighterRedLink,
      required this.fighterBlueLink,
      required this.fighterRedFlag,
      required this.fighterBlueFlag,
      required this.fighterRedCountry,
      required this.fighterBlueCountry});

  final String fighterRedName;
  final String fighterBlueName;
  final String fighterRedOdd;
  final String fighterBlueOdd;
  final String fightWeightclass;
  final String fighterRedLastName;
  final String fighterBlueLastName;
  final String fighterRedBodyshot;
  final String fighterBlueBodyshot;
  final String fighterRedLink;
  final String fighterBlueLink;
  final String fighterRedFlag;
  final String fighterBlueFlag;
  final String fighterRedCountry;
  final String fighterBlueCountry;

  @override
  State<FightDetails> createState() => _FightDetailsState();
}

class _FightDetailsState extends State<FightDetails> {
  String recordRedFighter = '';
  String recordBlueFighter = '';
  final shadowRed =
      'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_RED.png?VersionId=0NwYm4ow5ym9PWjgcpd05ObDBIC5pBtX&itok=woJQm5ZH';
  final shadowBlue =
      'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_BLUE.png?VersionId=1Jeml9w1QwZqmMUJDg8qTrTk7fFhqUra&itok=fiyOmUkc';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String convertHeightToFeetAndInches(String heightInches) {
    final height = double.tryParse(heightInches) ?? 0.0;

    if (height <= 0) {
      return '0\'0"';
    }

    final feet = height ~/ 12;
    final inches = (height - (feet * 12)).round();

    return '$feet\'$inches"';
  }

  Future<Map<String, String>> fetchFighter(String fighterUrl) async {
    try {
      final response = await http.get(Uri.parse(fighterUrl));
      final document = html_parser.parse(response.body);

      //hero-profile__division-body
      String record =
          document.querySelector('.hero-profile__division-body')?.text ?? '';
      final basicElements = document.querySelectorAll('.c-bio__label');
      final winsBreakdown = document.querySelectorAll('.c-stat-3bar__value');

      try {
        record = record
            .toString()
            .substring(0, 7)
            .replaceAll('W', '')
            .replaceAll('(', '');
      } catch (e) {
        record = 'N/A';
      }

      String age = '';
      String height = '';
      String weight = '';
      String reach = '';

      for (var labelElement in basicElements) {
        // Get the label text
        final labelText = labelElement.text.trim();

        final valueElement = labelElement.nextElementSibling;
        if (valueElement != null) {
          final valueText = valueElement.text.trim();
          switch (labelText) {
            case 'Age':
              age = valueText;
              break;
            case 'Height':
              height = valueText;
              break;
            case 'Weight':
              weight = valueText;
              break;
            case 'Reach':
              reach = '$valueText"';
              break;
          }
        }
      }

      if (age.isEmpty) {
        age = 'N/A';
      }
      if (height.isEmpty) {
        height = 'N/A';
      } else {
        height = convertHeightToFeetAndInches(height);
      }
      if (weight.isEmpty) {
        weight = 'N/A';
      }
      if (reach.isEmpty) {
        reach = 'N/A';
      }

      String koPercentage = '';
      String decPercentage = '';
      String subPercentage = '';

      String ko = '';
      String sub = '';
      String dec = '';

      try {
        koPercentage = winsBreakdown[3]
            .text
            .trim()
            .substring(3, 6)
            .replaceAll(RegExp('[() %]'), '');

        decPercentage = winsBreakdown[4]
            .text
            .trim()
            .substring(3, 6)
            .replaceAll(RegExp('[() %]'), '');
        subPercentage = winsBreakdown[5]
            .text
            .trim()
            .substring(3, 6)
            .replaceAll(RegExp('[() %]'), '');

        ko = winsBreakdown[3].text.trim().substring(0, 3).replaceAll('(', '');

        dec = winsBreakdown[4].text.trim().substring(0, 3).replaceAll('(', '');
        sub = winsBreakdown[5].text.trim().substring(0, 3).replaceAll('(', '');
      } catch (e) {
        koPercentage = '0';
        decPercentage = '0';
        subPercentage = '0';
        ko = 'N/A';
        dec = 'N/A';
        sub = 'N/A';
      }

      return {
        'record': record,
        'age': age,
        'height': height,
        'reach': reach,
        'weight': weight,
        'koPerc': koPercentage,
        'subPerc': subPercentage,
        'decPerc': decPercentage,
        'ko': ko,
        'sub': sub,
        'dec': dec,
        // Add other data points as needed
      };
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: Future.wait([
        fetchFighter(widget.fighterRedLink),
        fetchFighter(widget.fighterBlueLink),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, display a circular progress indicator.
          return FightLoadingPage(
            fighterLastNameRed: widget.fighterRedLastName,
            fighterLastNameBlue: widget.fighterBlueLastName,
          );
        } else if (snapshot.hasError) {
          // If there was an error fetching data, display an error message.
          return Scaffold(
            backgroundColor: primary,
            appBar: SuckMyBar(
              title:
                  '${widget.fighterRedLastName}  VS  ${widget.fighterBlueLastName}',
              title2: 'HEAD-TO-HEAD',
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: accent,
                  size: 75,
                ),
                Text(
                  'Error: ${snapshot.error}',
                  style: eventTitle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          // If data has been successfully fetched, update your UI with the data.
          final List<Map<String, String>> fighterData =
              snapshot.data as List<Map<String, String>>;
          final Map<String, String> redFighterData = fighterData[0];
          final Map<String, String> blueFighterData = fighterData[1];

          // Now you can use redFighterData and blueFighterData to access different data points.
          return Scaffold(
            appBar: SuckMyBar(
              title:
                  '${widget.fighterRedLastName}  VS  ${widget.fighterBlueLastName}',
              title2: 'HEAD-TO-HEAD',
            ),
            backgroundColor: primary,
            body: Stack(
              children: [
                BackgroundPattern(
                  opacity: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: screenWidth / 1.03,
                          decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Image.network(
                                        widget.fighterRedBodyshot,
                                        height: widget.fighterRedBodyshot
                                                .contains('question')
                                            ? 100
                                            : 360,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return Image.network(
                                              height: 360,
                                              fit: BoxFit.fitHeight,
                                              shadowRed);
                                        }, // or any other widget to indicate an error
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // Image is fully loaded.
                                          }
                                          return const CircularProgressIndicator(
                                            color: Colors.black,
                                          ); // Display a loading spinner.
                                        },
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Image.network(
                                    widget.fighterBlueBodyshot,
                                    fit: BoxFit.cover,
                                    height: widget.fighterBlueBodyshot
                                            .contains('question')
                                        ? 100
                                        : 360,
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      return Image.network(
                                          height: 360,
                                          fit: BoxFit.fitHeight,
                                          shadowRed);
                                    }, // or any other widget to indicate an error
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // Image is fully loaded.
                                      }
                                      return const CircularProgressIndicator(
                                        color: Colors.black,
                                      ); // Display a loading spinner.
                                    },
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.fighterRedCountry,
                                    style: fighterTextSmaller,
                                    textAlign: TextAlign.end,
                                  ),
                                  Image.network(
                                    widget.fighterRedFlag,
                                    width: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Image.network(
                                    widget.fighterBlueFlag,
                                    width: 30,
                                  ),
                                  Text(
                                    widget.fighterBlueCountry,
                                    style: fighterTextSmaller,
                                    textAlign: TextAlign.start,
                                  ),
                                  const Spacer(),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                      child: SizedBox(
                                    height: 1,
                                  )),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          redFighterData['record'].toString(),
                                          style: nigger,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: redFighterData['weight']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                              TextSpan(
                                                  text: '  LBS',
                                                  style: fighterTextSmallGrey),
                                            ],
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: redFighterData['height']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: redFighterData['reach']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          redFighterData['age'].toString(),
                                          style: nigger,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          widget.fighterRedOdd,
                                          style: nigger,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          '{keshboy}',
                                          style: nigger,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'RECORD',
                                          style: nig,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'WEIGHT',
                                          style: nig,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                          width: 90,
                                          child: Text(
                                            'HEIGHT',
                                            style: nig,
                                            textAlign: TextAlign.center,
                                          )),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                          width: 90,
                                          child: Text(
                                            'REACH',
                                            style: nig,
                                            textAlign: TextAlign.center,
                                          )),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'AGE',
                                          style: nig,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'ODDS',
                                          style: nig,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'PREDICTION',
                                          style: nig,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          blueFighterData['record'].toString(),
                                          style: nigger,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: blueFighterData['weight']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                              TextSpan(
                                                  text: '  LBS',
                                                  style: fighterTextSmallGrey),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: blueFighterData['height']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: blueFighterData['reach']
                                                    .toString(),
                                                style: nigger,
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          blueFighterData['age'].toString(),
                                          style: nigger,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          widget.fighterBlueOdd,
                                          style: nigger,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          '{keshboy}',
                                          style: nigger,
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 1,
                                  )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
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
                                      labelPosition:
                                          ChartDataLabelPosition.inside,
                                      opposedPosition: true,
                                      majorTickLines:
                                          const MajorTickLines(size: 0),
                                      majorGridLines:
                                          const MajorGridLines(width: 0),
                                      minorGridLines:
                                          const MinorGridLines(width: 0),
                                      axisLine: const AxisLine(width: 0),
                                    ),
                                    primaryYAxis: CategoryAxis(
                                      visibleMinimum: 0,
                                      labelStyle: const TextStyle(
                                          color: Colors.transparent),
                                      maximum: 100,
                                      minimum: 0,
                                      majorTickLines:
                                          const MajorTickLines(size: 0),
                                      majorGridLines:
                                          const MajorGridLines(width: 0),
                                      minorGridLines:
                                          const MinorGridLines(width: 0),
                                      axisLine: const AxisLine(width: 0),
                                    ),
                                    series: <ChartSeries>[
                                      BarSeries<String, String>(
                                          color: accent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          dataSource: const <String>[
                                            '        DEC',
                                            '        SUB',
                                            'KO/TKO',
                                          ],
                                          xValueMapper: (String item, _) =>
                                              item,
                                          yValueMapper: (String item, _) {
                                            // Define different values for each category
                                            if (item == 'KO/TKO') {
                                              return int.parse(
                                                '${redFighterData['koPerc']}',
                                              ); // Set the value for 'KO/TKO'
                                            } else if (item == '        SUB') {
                                              return int.parse(
                                                '${redFighterData['subPerc']}',
                                              ); // Set the value for 'SUB'
                                            } else if (item == '        DEC') {
                                              return int.parse(
                                                '${redFighterData['decPerc']}'
                                                    .toString(),
                                              ); // Set the value for 'DEC'
                                            }
                                            return 0; // Default value
                                          },
                                          dataLabelMapper: (String item, _) {
                                            // Customize the data label text
                                            String extraInfo;
                                            if (item == 'KO/TKO') {
                                              extraInfo =
                                                  '${redFighterData['ko']} W / ${redFighterData['koPerc']} %';
                                            } else if (item == '        SUB') {
                                              extraInfo =
                                                  '${redFighterData['sub']} W / ${redFighterData['subPerc']} %';
                                            } else if (item == '        DEC') {
                                              extraInfo =
                                                  '${redFighterData['dec']} W / ${redFighterData['decPerc']} %';
                                            } else {
                                              extraInfo = ''; // Default value
                                            }
                                            return extraInfo;
                                          },
                                          spacing: 0.4,
                                          width: 0.65,
                                          borderWidth: 1,
                                          borderColor: accent,
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
                                          trackColor: lightGrey),
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
                                      labelPosition:
                                          ChartDataLabelPosition.inside,
                                      majorTickLines:
                                          const MajorTickLines(size: 0),
                                      majorGridLines:
                                          const MajorGridLines(width: 0),
                                      minorGridLines:
                                          const MinorGridLines(width: 0),
                                      axisLine: const AxisLine(width: 0),
                                    ),
                                    primaryYAxis: CategoryAxis(
                                      isInversed: true,
                                      visibleMinimum: 0,
                                      labelStyle: const TextStyle(
                                          color: Colors.transparent),
                                      maximum: 100,
                                      minimum: 0,
                                      majorTickLines:
                                          const MajorTickLines(size: 0),
                                      majorGridLines:
                                          const MajorGridLines(width: 0),
                                      minorGridLines:
                                          const MinorGridLines(width: 0),
                                      axisLine: const AxisLine(width: 0),
                                    ),
                                    series: <ChartSeries>[
                                      BarSeries<String, String>(
                                          color: accent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          dataSource: const <String>[
                                            'DEC',
                                            'SUB',
                                            'KO/TKO',
                                          ],
                                          xValueMapper: (String item, _) =>
                                              item,
                                          yValueMapper: (String item, _) {
                                            // Define different values for each category
                                            if (item == 'KO/TKO') {
                                              return int.parse(
                                                '${blueFighterData['koPerc']}',
                                              ); // Set the value for 'KO/TKO'
                                            } else if (item == 'SUB') {
                                              return int.parse(
                                                '${blueFighterData['subPerc']}',
                                              ); // Set the value for 'SUB'
                                            } else if (item == 'DEC') {
                                              return int.parse(
                                                '${blueFighterData['decPerc']}'
                                                    .toString(),
                                              ); // Set the value for 'DEC'
                                            }
                                            return 0; // Default value
                                          },
                                          dataLabelMapper: (String item, _) {
                                            // Customize the data label text
                                            String extraInfo;
                                            if (item == 'KO/TKO') {
                                              extraInfo =
                                                  '${blueFighterData['ko']} W / ${blueFighterData['koPerc']} %';
                                            } else if (item == 'SUB') {
                                              extraInfo =
                                                  '${blueFighterData['sub']} W / ${blueFighterData['subPerc']} %';
                                            } else if (item == 'DEC') {
                                              extraInfo =
                                                  '${blueFighterData['dec']} W / ${blueFighterData['decPerc']} %';
                                            } else {
                                              extraInfo = ''; // Default value
                                            }
                                            return extraInfo;
                                          },
                                          spacing: 0.4,
                                          width: 0.65,
                                          borderWidth: 1,
                                          borderColor: accent,
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
                                          trackColor: lightGrey),
                                    ],
                                    plotAreaBorderColor: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
