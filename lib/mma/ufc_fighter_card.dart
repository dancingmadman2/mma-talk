import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:mma_talk/components/loading_pages/fighter_loading_page.dart';

import 'package:mma_talk/components/styles.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import '../components/appbar.dart';

//import '../components/appbar_fighter.dart';
//import 'package:html/dom.dart' as html_dom;

class FighterDetails extends StatefulWidget {
  const FighterDetails({
    super.key,
    required this.fighterName,
    required this.fighterCountry,
    required this.fighterFlag,
    required this.fighterLink,
    required this.fighterBodyshot,
  });

  final String fighterName;

  final String fighterBodyshot;
  final String fighterFlag;
  final String fighterCountry;
  final String fighterLink;

  @override
  State<FighterDetails> createState() => _FighterDetailsState();
}

class _FighterDetailsState extends State<FighterDetails> {
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

  Map<String, String> extractRecord(String recordString) {
    // Define the pattern for matching wins, losses, and draws
    final pattern = RegExp(r'(\d+)-(\d+)-(\d+)');
    final match = pattern.firstMatch(recordString);

    if (match != null) {
      // Extract the wins, losses, and draws as strings
      String wins = match.group(1)!;
      String losses = match.group(2)!;
      String draws = match.group(3)!;

      return {'wins': wins, 'losses': losses, 'draws': draws};
    } else {
      return {
        'wins': '0',
        'losses': '0',
        'draws': '0'
      }; // Return default values if no match is found
    }
  }

  Future<Map<String, dynamic>> fetchFighter() async {
    Map<String, dynamic> sandbox = {};

    try {
      final response = await http.get(Uri.parse(widget.fighterLink));
      final document = html_parser.parse(response.body);

      final name = document.querySelector('.hero-profile__name')?.text ?? '';
      final fighterImageSource = document.querySelector('.hero-profile__image');
      final division =
          document.querySelector('.hero-profile__division-title')?.text ?? '';
      final nickname =
          document.querySelector('.hero-profile__nickname')?.text ?? '';
      final record =
          document.querySelector('.hero-profile__division-body')?.text ?? '';
      //final bio = document.querySelectorAll('.c-bio__text');
      final bio = document.querySelectorAll('.c-bio__label');
      final more = document.querySelectorAll('.c-stat-compare__number');
      final morePercent = document.querySelectorAll('.e-chart-circle__percent');
      final winsBreakdown = document.querySelectorAll('.c-stat-3bar__value');
      final fighterImageRed = document
          .querySelectorAll('.c-card-event--athlete-results__red-image');
      final fighterImageBlue = document
          .querySelectorAll('.c-card-event--athlete-results__blue-image');
      final dateElements =
          document.querySelectorAll('.c-card-event--athlete-results__date');
      //c-card-event--athlete-results__date
      final fightFinishElements = document
          .querySelectorAll('.c-card-event--athlete-results__result-text');
      final resultLabel = document
          .querySelectorAll('.c-card-event--athlete-results__result-label');
      final resultsA =
          document.querySelectorAll('.c-card-event--athlete-results');

      final fullName = widget.fighterName;
      final nameParts = fullName.split(' ');

      String imageUrl = fighterImageSource?.attributes['src'] ??
          'https://dmxg5wxfqgb4u.cloudfront.net/styles/athlete_bio_full_body/s3/image/fighter_images/SHADOW_Fighter_fullLength_RED.png?VersionId=niQpXmYT1tbiETIDAxTsCI5FDbiNt9kI&itok=Wcqi-8Me';

      String age = '';
      String height = '';
      String weight = '';
      String reach = '';

      double sAccuracy = 0;
      double tAccuracy = 0;

      String sigStrikesAccuracy = '';
      String takedownAccuracy = '';
      String sigStrikesLanded = '';
      String takedownAverage = '';
      String sigStrikesDefense = '';
      String takedownDefense = '';

      String koPercentage = '';
      String decPercentage = '';
      String subPercentage = '';

      Map<String, String> recordNumbers = extractRecord(record);

      String wins = recordNumbers['wins']!;
      String losses = recordNumbers['losses']!;
      String draws = recordNumbers['draws']!;

      String ko = '';
      String sub = '';
      String dec = '';

      for (var labelElement in bio) {
        final labelText = labelElement.text.trim();
        // Use the label text as a key to find the corresponding value
        final valueElement = labelElement.nextElementSibling;
        if (valueElement != null) {
          final valueText = valueElement.text.trim();

          sandbox[labelText] = valueText;

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

      try {
        sigStrikesAccuracy = morePercent[0].text.trim();

        sAccuracy = double.parse(sigStrikesAccuracy.replaceAll('%', ''));
      } catch (e) {
        sigStrikesAccuracy = 'N/A';
      }

      try {
        takedownAccuracy = morePercent[1].text.trim();
        tAccuracy = double.parse(takedownAccuracy.replaceAll('%', ''));
      } catch (e) {
        takedownAccuracy = 'N/A';
      }

      final sectionsStriking = [
        PieChartSectionData(
            value: 100 - sAccuracy, color: lightGrey, showTitle: false),
        PieChartSectionData(
          value: sAccuracy,
          title: '$sAccuracy %',
          titleStyle: fighterTextBig,
          titlePositionPercentageOffset: -0.8,
          color: accent,
        ),
      ];

      final sectionsTakedown = [
        PieChartSectionData(
            value: 100 - tAccuracy, color: lightGrey, showTitle: false),
        PieChartSectionData(
          value: tAccuracy,
          title: '$tAccuracy %',
          titleStyle: fighterTextBig,
          titlePositionPercentageOffset: -0.8,
          color: accent,
        ),
      ];

      final pieChartDataStriking = PieChartData(
        sections: sectionsStriking,
        centerSpaceRadius: 30,
      );
      final pieChartDataTakedown = PieChartData(
        sections: sectionsTakedown,
        centerSpaceRadius: 30,
      );

      try {
        sigStrikesLanded = more[0].text.trim();
      } catch (e) {
        sigStrikesLanded = 'N/A';
      }
      try {
        takedownAverage = more[2].text.trim();
      } catch (e) {
        takedownAverage = 'N/A';
      }
      try {
        sigStrikesDefense =
            more[4].text.trim().replaceAll('\n', '').replaceAll(' ', '');
      } catch (e) {
        sigStrikesDefense = 'N/A';
      }
      try {
        takedownDefense =
            more[5].text.trim().replaceAll('\n', '').replaceAll(' ', '');
      } catch (e) {
        takedownDefense = 'N/A';
      }

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

      final fighterNames = document
          .querySelectorAll('h3.c-card-event--athlete-results__headline a')
          .map((element) {
        return element.text;
      }).toList();

      final List<String> fightDates = [];

      for (final dateElement in dateElements) {
        final dateText = dateElement.text;
        fightDates.add(dateText);
      }

      final List<bool> fighterHistoryRed = [];
      final List<bool> fighterHistoryBlue = [];

      final List<String> fighterHeadshotsRed = [];
      final List<String> fighterHeadshotsBlue = [];
      final List<String> fighterNamesRed = [];
      final List<String> fighterNamesBlue = [];

      if (fighterNames.isNotEmpty) {
        for (int i = 0; i < fighterNames.length; i += 2) {
          fighterNamesRed.add(fighterNames[i]);
        }
        for (int i = 1; i < fighterNames.length; i += 2) {
          fighterNamesBlue.add(fighterNames[i]);
        }
      }

      for (int i = 0; i < fighterImageBlue.length; i++) {
        final winElementBlue = fighterImageBlue[i]
            .querySelector('.c-card-event--athlete-results__plaque.win');

        final winElementRed = fighterImageRed[i]
            .querySelector('.c-card-event--athlete-results__plaque.win');

        if (winElementBlue != null) {
          fighterHistoryRed.add(false);
          fighterHistoryBlue.add(true);
        } else if (winElementRed != null) {
          fighterHistoryBlue.add(false);
          fighterHistoryRed.add(true);
        } else {
          fighterHistoryBlue.add(false);
          fighterHistoryRed.add(false);
        }
      }

      final List<String> fightFinishMethod = [];
      for (int i = 0; i < resultsA.length; i++) {
        final resultsB = resultsA[i]
            .querySelector('.c-card-event--athlete-results__results');
        if (resultsB != null) {
          for (int i = 0; i < resultLabel.length; i++) {
            if (resultLabel[i].text == 'Method') {
              fightFinishMethod.add(fightFinishElements[i].text);
            }
          }
          break;
        } else {
          fightFinishMethod.add('N/A');
        }
      }
      for (int i = 0; i < fightFinishMethod.length; i++) {
        if (fighterHistoryRed[i] == false && fighterHistoryBlue[i] == false) {
          fightFinishMethod[i] = 'DRAW  ${fightFinishMethod[i]}';
        }
      }

      for (final divElement in fighterImageRed) {
        final imageElement = divElement.querySelector('img');
        if (imageElement != null) {
          final imageUrl = imageElement.attributes['src'];
          if (imageUrl != null) {
            if (!imageUrl.contains('https')) {
              fighterHeadshotsRed.add('https://ufc.com$imageUrl');
            } else {
              fighterHeadshotsRed.add(imageUrl);
            }
          }
        } else {
          fighterHeadshotsRed.add('https://i.ibb.co/QF0cG4m/white.png');
        }
        fighterHeadshotsBlue.clear();
        for (final divElement in fighterImageBlue) {
          final imageElement = divElement.querySelector('img');
          if (imageElement != null) {
            final imageUrl = imageElement.attributes['src'];
            if (imageUrl != null) {
              if (!imageUrl.contains('https')) {
                fighterHeadshotsBlue.add('https://ufc.com$imageUrl');
              } else {
                fighterHeadshotsBlue.add(imageUrl);
              }
            }
          } else {
            fighterHeadshotsBlue.add('https://i.ibb.co/QF0cG4m/white.png');
          }
        }
      }

      sandbox = {
        'name': name,
        'image': imageUrl,
        'firstName': nameParts.first,
        'lastName': nameParts.last,
        'division': division,
        'nickname': nickname,
        'record': record,
        'wins': wins,
        'losses': losses,
        'draws': draws,
        'age': age,
        'height': height,
        'weight': weight,
        'reach': reach,
        'strikesLanded': sigStrikesLanded,
        'strikesAccuracy': sigStrikesAccuracy,
        'strikesDefense': sigStrikesDefense,
        'takedownAverage': takedownAverage,
        'takedownAccuracy': takedownAccuracy,
        'takedownDefense': takedownDefense,
        'piechartStriking': pieChartDataStriking,
        'piechartTakedown': pieChartDataTakedown,
        'koPerc': koPercentage,
        'subPerc': subPercentage,
        'decPerc': decPercentage,
        'ko': ko,
        'sub': sub,
        'dec': dec,
        'fighterNamesRed': fighterNamesRed,
        'fighterNamesBlue': fighterNamesBlue,
        'fighterHistoryRed': fighterHistoryRed,
        'fighterHistoryBlue': fighterHistoryBlue,
        'fighterHeadshotsRed': fighterHeadshotsRed,
        'fighterHeadshotsBlue': fighterHeadshotsBlue,
        'fightDates': fightDates,
        'fightFinish': fightFinishMethod,
      };

      return sandbox;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: fetchFighter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, display a circular progress indicator.
            return FighterLoadingPage(
              fighterName: widget.fighterName,
            );
          } else if (snapshot.hasError) {
            // If there was an error fetching data, display an error message.
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final Map<String, dynamic> fighterData = snapshot.data!;

            return Scaffold(
              backgroundColor: primary,
              appBar: SuckMyBar(
                title: widget.fighterName,
                title2: fighterData['nickname'],
              ),
              body: SingleChildScrollView(
                child: Center(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    /*
                                    SizedBox(
                                      height: !fighterData['division']
                                              .toString()
                                              .toLowerCase()
                                              .contains('women')
                                          ? 85
                                          : 110,
                                    ),*/
                                    Image.network(fighterData['image'],
                                        height: !fighterData['image']
                                                .toString()
                                                .contains('question')
                                            ? 250
                                            : 150,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // Image is fully loaded.
                                      }
                                      return const CircularProgressIndicator(
                                        color: Colors.black,
                                      );
                                    }),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 130,
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            fighterData['firstName'],
                                            style: fighterTitleLight,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            fighterData['lastName'],
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
                                              if (widget.fighterFlag.length > 1)
                                                Image.network(
                                                  widget.fighterFlag,
                                                  height: 30,
                                                ),
                                              Text(
                                                widget.fighterCountry,
                                                style: fighterCountry,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            fighterData['division'],
                                            style: fighterTextSmall,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    'Height',
                                                    style: fighterTextSmallGrey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    'Weight',
                                                    style: fighterTextSmallGrey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    'Reach',
                                                    style: fighterTextSmallGrey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  child: Text(
                                                    'Age',
                                                    style: fighterTextSmallGrey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width: 95,
                                                  child: Text(
                                                    fighterData['height'],
                                                    style: statsSmall,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 95,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        child: Text(
                                                          fighterData['weight'],
                                                          style: statsSmall,
                                                        ),
                                                      ),
                                                      Text(
                                                        '  lbs',
                                                        style: fighterTextTiny,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 95,
                                                  child: Text(
                                                    fighterData['reach'],
                                                    style: statsSmall,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 95,
                                                  child: Text(
                                                    fighterData['age'],
                                                    style: statsSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
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
                            color: background,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(children: [
                          const SizedBox(height: 15),
                          Text(
                            'STATS & RECORDS',
                            style: fighterTitle,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 75,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      topLeft: Radius.circular(8)),
                                  color: primary,
                                ),
                                child: Center(
                                  child: Text(
                                    'WINS',
                                    style: statsWhite,
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                    border: Border.all(color: primary)),
                                child: Center(
                                  child: Text(
                                    fighterData['wins'],
                                    style: statsPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Container(
                                width: 75,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      topLeft: Radius.circular(8)),
                                  color: primary,
                                ),
                                child: Center(
                                  child: Text(
                                    'LOSSES',
                                    style: statsWhite,
                                  ),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                    border: Border.all(color: primary)),
                                child: Center(
                                  child: Text(
                                    fighterData['losses'],
                                    style: statsPrimary,
                                  ),
                                ),
                              ),
                            ],
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
                                    color: accent,
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
                                          fighterData['koPerc'],
                                        ); // Set the value for 'KO/TKO'
                                      } else if (item == 'SUB') {
                                        return int.parse(
                                          fighterData['subPerc'],
                                        ); // Set the value for 'SUB'
                                      } else if (item == 'DEC') {
                                        return int.parse(
                                          fighterData['decPerc'],
                                        ); // Set the value for 'DEC'
                                      }
                                      return 0; // Default value
                                    },
                                    dataLabelMapper: (String item, _) {
                                      // Customize the data label text
                                      String extraInfo;
                                      if (item == 'KO/TKO') {
                                        extraInfo =
                                            '${fighterData['ko']} W / ${fighterData['koPerc']} %';
                                      } else if (item == 'SUB') {
                                        extraInfo =
                                            '${fighterData['sub']} W / ${fighterData['subPerc']} %';
                                      } else if (item == 'DEC') {
                                        extraInfo =
                                            '${fighterData['dec']} W / ${fighterData['decPerc']} %';
                                      } else {
                                        extraInfo = ''; // Default value
                                      }
                                      return extraInfo;
                                    },
                                    spacing: 0.25,
                                    width: 0.65,
                                    borderWidth: 1,
                                    borderColor: accent,
                                    dataLabelSettings: DataLabelSettings(
                                      labelAlignment:
                                          ChartDataLabelAlignment.auto,
                                      isVisible: true,
                                      textStyle: fighterText,
                                    ),
                                    isTrackVisible: true,
                                    trackColor: lightGrey),
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
                                  SizedBox(
                                      width: 75,
                                      height: 75,
                                      child: PieChart(
                                          fighterData['piechartStriking'])),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Text(
                                    fighterData['strikesLanded'],
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
                                    fighterData['strikesDefense'],
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
                                  SizedBox(
                                      width: 75,
                                      height: 75,
                                      child: PieChart(
                                          fighterData['piechartTakedown'])),
                                  const SizedBox(
                                    height: 60,
                                  ),
                                  Text(
                                    fighterData['takedownAverage'],
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
                                    fighterData['takedownDefense'],
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
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'FIGHTER HISTORY',
                        style: fighterTitleWhite,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      for (int i = 0;
                          i < fighterData['fighterNamesRed'].length;
                          i++)
                        Column(
                          children: [
                            Container(
                              width: screenWidth / 1.03,
                              decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        fighterData['fighterNamesRed'][i],
                                        style: fighterData['fighterHistoryRed']
                                                    [i] ==
                                                true
                                            ? stats
                                            : fighterTextAlmostBig,
                                      ),
                                      const SizedBox(
                                        width: 6.5,
                                      ),
                                      Text(
                                        'VS',
                                        style: fighterTextSmallGrey,
                                      ),
                                      const SizedBox(
                                        width: 6.5,
                                      ),
                                      Text(
                                        fighterData['fighterNamesBlue'][i],
                                        style: fighterData['fighterHistoryBlue']
                                                    [i] ==
                                                true
                                            ? stats
                                            : fighterTextAlmostBig,
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                fighterData['fightDates'][i],
                                                style: fighterTextSmallGrey,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              if (i <
                                                  fighterData['fightFinish']
                                                      .length)
                                                Text(
                                                  fighterData['fightFinish']
                                                          [i] ??
                                                      '',
                                                  style: fighterTextSmall,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.network(
                                            fighterData['fighterHeadshotsRed']
                                                [i],
                                            scale: 2.5,
                                          ),
                                          const Spacer(),
                                          Image.network(
                                            fighterData['fighterHeadshotsBlue']
                                                [i],
                                            scale: 2.5,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
