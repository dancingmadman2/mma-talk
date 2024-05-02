import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:mma_talk/components/appbar.dart';

import 'package:mma_talk/components/chat/chat.dart';
import 'package:mma_talk/components/parseLiveJson/secrape.dart';

import 'package:mma_talk/components/styles.dart';
import 'package:html/dom.dart' as html;

import 'package:mma_talk/mma/fight_box.dart';

import 'package:skeletonizer/skeletonizer.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({
    super.key,
    required this.eventNameSelection,
    required this.eventDateSelection,
    required this.eventLink,
    required this.eventType,
    required this.isLive,
  });
  final String eventNameSelection;
  final String eventDateSelection;
  final String eventLink;
  final bool isLive;
  final String eventType;

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

late ValueNotifier<int?> liveFightNotifier;

class _EventDetailsState extends State<EventDetails>
    with TickerProviderStateMixin {
  int currentEvent = 0;
  int maincardLength = 0;
  int prelimsLength = 0;
  String eventName = '';
  String eventDate = '';
  String formattedDate = '';
  int cardLength = 0;

  late AnimationController _translationController;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  final double _imageWidth = 141;
  late Map<String, dynamic> sand;
  bool isLoading = false;
  String? errorMessage;

  late Future<Map<String, dynamic>> _future;
  Timer? _dataFetchTimer;
  late PageController _pageController;

  late ValueNotifier<int> _currentPageNotifier;

  late ValueNotifier<bool> _errorNotifier;

  @override
  void initState() {
    super.initState();

    _future = fetchEventAndPreloadImages();

    _currentPageNotifier = ValueNotifier(0);
    _errorNotifier = ValueNotifier(false);
    liveFightNotifier = ValueNotifier(31);

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
    _pageController.addListener(() {
      int nextPage = _pageController.page!.round();
      _currentPageNotifier.value = nextPage;
    });

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duration for one rotation
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5)
        .animate(_rotationController); // 180 degrees rotation

    _translationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _translationController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _translationController.reverse();
          _rotationController.forward(from: 0.0);
          break;

        case AnimationStatus.dismissed:
          _translationController.forward();
          _rotationController.reverse(from: 1.0);
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _translationController.forward();
    // _translationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    if (mounted) {
      _translationController.dispose();
      _rotationController.dispose();

      _errorNotifier.dispose();
      liveFightNotifier.dispose();
      _pageController.dispose();
      _currentPageNotifier.dispose();
    }

    super.dispose();
  }

  List<String> extractAndProcessFighterNames(
      List<html.Element> fighterNameElements) {
    List<String> fighterNames = [];

    for (final element in fighterNameElements) {
      final nameNode = element.querySelector('a')?.text;
      if (nameNode != null) {
        final fighterName = nameNode.replaceAll('\n', '').trim();
        fighterNames.add(fighterName);
      }
    }
    // Remove duplicates and clean up names
    fighterNames = fighterNames
        .map((name) => name.trim().replaceAll(RegExp(r'\s+'), ' '))
        .toSet()
        .toList();

    return fighterNames;
  }

  List<String> getLastNames(List<String> fullNames) {
    List<String> lastNames = [];

    for (final fullName in fullNames) {
      final parts = fullName.replaceAll('-', ' ').split(' ');

      if (parts.length > 1) {
        // Check if the full name has at least two parts (first name and last name)
        // If yes, concatenate all parts except the first one as the last name
        if (fullName.contains('Jr')) {
          final lastName = parts.skip(1).join(' ');
          lastNames.add(lastName);
        } else {
          final lastName = parts.last;
          lastNames.add(lastName);
        }
      } else {
        // Handle cases where there is no space-separated last name
        // You can choose to ignore or handle these cases differently
        lastNames.add(fullName);
      }
    }

    return lastNames;
  }

  void splitFighterOdds(List<String> fighterOdds, List<String> fighterOddsRed,
      List<String> fighterOddsBlue) {
    for (int i = 0; i < fighterOdds.length; i++) {
      final odds = fighterOdds[i];
      if (i % 2 == 0) {
        fighterOddsRed.add(odds);
      } else {
        fighterOddsBlue.add(odds);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> loadImages(List<String> imageUrls) async {
    try {
      // load network image example
      for (int i = 0; i < imageUrls.length; i++) {
        await precacheImage(NetworkImage(imageUrls[i]), context);
      }
      //print('Image loaded and cached successfully!');
    } catch (e) {
      //print('Failed to load and cache the image: $e');
    }
  }

  // lazy load first four images
  Future<void> preloadImagesRed() async {
    List<String> imageUrls = List<String>.from(sand['fighterBodyshotsRed']);
    for (int i = 0; i < 4; i++) {
      try {
        await precacheImage(NetworkImage(imageUrls[i]), context);
      } catch (e) {
        //print('Failed to preload image: ${imageUrls[i]}. Error: $e');
        // Handle the error, e.g., logging or setting an error flag
      }
    }
  }

  Future<void> preloadImagesBlue() async {
    List<String> imageUrls = List<String>.from(sand['fighterBodyshotsBlue']);
    for (int i = 0; i < 4; i++) {
      try {
        await precacheImage(NetworkImage(imageUrls[i]), context);
      } catch (e) {
        //print('Failed to preload image: ${imageUrls[i]}. Error: $e');
        // Handle the error, e.g., logging or setting an error flag
      }
    }
  }

  Future<Map<String, dynamic>> fetchEventAndPreloadImages() async {
    try {
      // Fetch the event data
      var eventData = await fetchEvent();

      // Assuming 'eventData' contains your image URLs
      List<String> redImageUrls =
          List<String>.from(eventData['fighterBodyshotsRed']);
      List<String> blueImageUrls =
          List<String>.from(eventData['fighterBodyshotsBlue']);

      // Preload images
      await Future.wait([
        ...redImageUrls
            .take(4)
            .map((url) => precacheImage(NetworkImage(url), context)),
        ...blueImageUrls
            .take(4)
            .map((url) => precacheImage(NetworkImage(url), context)),
      ]);

      // Return the fetched event data
      return eventData;
    } catch (e) {
      throw Exception('Failed to fetch event data and preload images: $e');
    }
  }

  Future<Live> fetchJsonData(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = liveFromJson(response.body);
      return data;
    } else {
      throw Exception('Failed to load JSON data');
    }
  }

  // fetch the ajax request
  Future<Map<String, dynamic>> loadEventData(int eventId) async {
    try {
      Live event = await fetchJsonData(
          'https://d29dxerjsp82wz.cloudfront.net/api/v3/event/live/$eventId.json');
      //Live event = await fetchJsonData(
      //  'https://dancingmadman2.github.io/test/test.json');

      final liveFightId = event.liveEventDetail.liveFightId;
      final liveRoundNumber = event.liveEventDetail.liveRoundNumber;
      int? liveFightOrder;

      for (var fight in event.liveEventDetail.fightCard) {
        if (fight.fightId == liveFightId) {
          liveFightOrder = fight.fightOrder; // Return the fight order
        }
      }
      Map<String, dynamic> liveDetails = {
        'liveFightId': liveFightId,
        'liveRoundNumber': liveRoundNumber,
        'liveFightOrder': liveFightOrder,
      };
      return liveDetails;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> fetchEvent() async {
    String url = 'https://www.ufc.com/${widget.eventLink}';

    try {
      final response = await http.get(Uri.parse(url));

      final document = html_parser.parse(response.body);

      final fighterNameElementsRed =
          document.querySelectorAll('.c-listing-fight__corner-name--red');
      final fighterNameElementsBlue =
          document.querySelectorAll('.c-listing-fight__corner-name--blue');
      final fighterWeightClassElements =
          document.querySelectorAll('.c-listing-fight__class-text');
      final maincardElements =
          document.querySelectorAll('div.main-card li.l-listing__item');
      final prelimsElements = document
          .querySelectorAll('div.fight-card-prelims li.l-listing__item');
      final fighterOddsElements =
          document.querySelectorAll('.c-listing-fight__odds-amount');
      final fighterCountryElementsRed =
          document.querySelectorAll('.c-listing-fight__country--red');
      final fighterCountryElementsBlue =
          document.querySelectorAll('.c-listing-fight__country--blue');
      final fighterFlagElementsRed =
          document.querySelectorAll('.c-listing-fight__country--red');
      final fighterFlagElementsBlue =
          document.querySelectorAll('.c-listing-fight__country--blue');
      final fighterLinkElementsRed =
          document.querySelectorAll('.c-listing-fight__corner-name--red a');
      final fighterLinkElementsBlue =
          document.querySelectorAll('.c-listing-fight__corner-name--blue a');
      final fighterBodyshotElementsRed =
          document.querySelectorAll('.c-listing-fight__corner-image--red');
      final fighterBodyshotElementsBlue =
          document.querySelectorAll('.c-listing-fight__corner-image--blue');

      final footerElement =
          document.querySelector('div.c-listing-ticker--footer');

      int eventId = 0;
      if (footerElement != null) {
        final eventIdElement = footerElement.attributes['data-fmid'] ?? '';
        try {
          eventId = int.parse(eventIdElement);
        } catch (e) {
          eventId = 0;
        }
      }

      Map<String, dynamic> liveDetails;
      int? liveFightId = 31;
      int? liveRoundNumber = 31;
      int? liveFightOrder = 31;
      if (widget.isLive) {
        // Now fetch live event data
        _dataFetchTimer =
            Timer.periodic(const Duration(seconds: 5), (Timer t) async {
          try {
            liveDetails = await loadEventData(eventId);
            // Update your state with the new data

            liveFightId = liveDetails['liveFightId'];
            liveRoundNumber = liveDetails['liveRoundNumber'];
            liveFightOrder = liveDetails['liveFightOrder'];
            liveFightNotifier.value = liveFightOrder;

            // Update your state here with the fetched data
          } catch (e) {
            print('Error fetching data: $e');
          }
        });
      }

      //final anan =
      //  document.querySelectorAll('div.c-listing-fight__banner--live.hidden');

      final outcomeRed =
          document.querySelectorAll('.c-listing-fight__corner-body--red');

      final outcomeBlue =
          document.querySelectorAll('.c-listing-fight__corner-body--blue');

      List<bool> fighterHistoryRed = [];
      List<bool> fighterHistoryBlue = [];

      for (int i = 0; i < outcomeRed.length; i++) {
        final winElementBlue = outcomeBlue[i].text.toString().trim();
        final winElementRed = outcomeRed[i].text.toString().trim();

        if (winElementBlue == 'Win') {
          fighterHistoryRed.add(false);
          fighterHistoryBlue.add(true);
        } else if (winElementRed == 'Win') {
          fighterHistoryBlue.add(false);
          fighterHistoryRed.add(true);
        } else {
          fighterHistoryBlue.add(false);
          fighterHistoryRed.add(false);
        }
      }

      if (fighterHistoryRed.isEmpty && fighterHistoryBlue.isEmpty) {
        fighterHistoryRed = List.generate(outcomeBlue.length, (index) => false);
        fighterHistoryBlue = List.generate(outcomeRed.length, (index) => false);
      }

      final maincardLength = maincardElements.length;
      final prelimsLength = prelimsElements.length;

      List<String> fighterNamesRed =
          extractAndProcessFighterNames(fighterNameElementsRed);
      List<String> fighterNamesBlue =
          extractAndProcessFighterNames(fighterNameElementsBlue);

      final cardLength = fighterNamesRed.length;

      List<String> lastNamesRed = getLastNames(fighterNamesRed);
      List<String> lastNamesBlue = getLastNames(fighterNamesBlue);

      final List<String> fighterDivision = List<String>.generate(
          fighterWeightClassElements.length ~/ 2,
          (i) => fighterWeightClassElements[i * 2].text);

      final List<String> fighterOdds =
          fighterOddsElements.map((element) => element.text).toList();

      List<String> fighterOddsRed = [];
      List<String> fighterOddsBlue = [];

      splitFighterOdds(fighterOdds, fighterOddsRed, fighterOddsBlue);

      final List<String> fighterCountriesRed = fighterCountryElementsRed
          .map((element) => element.text.trim())
          .toList();
      final List<String> fighterCountriesBlue = fighterCountryElementsBlue
          .map((element) => element.text.trim())
          .toList();

      List<String> fighterFlagsRed = [];
      List<String> fighterFlagsBlue = [];

      for (var divElement in fighterFlagElementsRed) {
        final imageElement = divElement.querySelector('img');
        final imageUrl = imageElement?.attributes['src'] ??
            'https://i.ibb.co/nDrwK1h/whitebakc.png';

        fighterFlagsRed.add(imageUrl);
      }
      for (var divElement in fighterFlagElementsBlue) {
        final imageElement = divElement.querySelector('img');
        final imageUrl = imageElement?.attributes['src'] ??
            'https://i.ibb.co/nDrwK1h/whitebakc.png';

        fighterFlagsBlue.add(imageUrl);
      }

      List<String> fighterLinksRed = [];
      List<String> fighterLinksBlue = [];

      for (final link in fighterLinkElementsRed) {
        final href = link.attributes['href'];

        fighterLinksRed.add(href.toString());
      }
      for (final link in fighterLinkElementsBlue) {
        final href = link.attributes['href'];

        fighterLinksBlue.add(href.toString());
      }

      List<String> fighterBodyshotsRed = [];
      List<String> fighterBodyshotsBlue = [];

      for (final divElement in fighterBodyshotElementsRed) {
        final imageElement = divElement.querySelector('img');
        if (imageElement != null) {
          final imageUrl = imageElement.attributes['src'];
          if (imageUrl != null) {
            if (imageUrl.toLowerCase().contains('themes') ||
                imageUrl.toLowerCase().contains('silhouette')) {
              fighterBodyshotsRed.add(
                  'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_RED.png?VersionId=0NwYm4ow5ym9PWjgcpd05ObDBIC5pBtX&itok=woJQm5ZH');
            } else if (!imageUrl.startsWith('https://')) {
              fighterBodyshotsRed.add('https://ufc.com$imageUrl');
            } else {
              fighterBodyshotsRed.add(imageUrl);
            }
          }
        }
      }

      for (final divElement in fighterBodyshotElementsBlue) {
        final imageElement = divElement.querySelector('img');
        if (imageElement != null) {
          final imageUrl = imageElement.attributes['src'];
          if (imageUrl != null) {
            if (imageUrl.toLowerCase().contains('themes') ||
                imageUrl.toLowerCase().contains('silhouette')) {
              fighterBodyshotsBlue.add(
                  'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_BLUE.png?VersionId=1Jeml9w1QwZqmMUJDg8qTrTk7fFhqUra&itok=fiyOmUkc');
            } else if (!imageUrl.startsWith('https://')) {
              fighterBodyshotsBlue.add('https://ufc.com$imageUrl');
            } else {
              fighterBodyshotsBlue.add(imageUrl);
            }
          }
        }
      }

      //String card = '';

      // card = widget.eventNameSelection.replaceAll(RegExp(r'[0-9]'), '');
      /*
      for (int i = 0; i < widget.fighterLabels.length; i++) {
        if (widget.fighterLabels[i].toString().trim() == card.trim()) {
          if (fighterHeadshotsRed.isNotEmpty) {
            fighterHeadshotsRed.removeRange(0, i);
            fighterHeadshotsBlue.removeRange(0, i);

            break;
          }
        }
      }*/

      //visibilityList[4] = false;
      Map<String, dynamic> sandbox = {
        'weightclass': fighterDivision,
        'fighterNamesRed': fighterNamesRed,
        'fighterNamesBlue': fighterNamesBlue,
        'lastNamesRed': lastNamesRed,
        'lastNamesBlue': lastNamesBlue,
        'maincardL': maincardLength,
        'prelimsL': prelimsLength,
        'cardLength': cardLength,
        'fighterOddsRed': fighterOddsRed,
        'fighterOddsBlue': fighterOddsBlue,
        'fighterCountriesRed': fighterCountriesRed,
        'fighterCountriesBlue': fighterCountriesBlue,
        'fighterFlagsRed': fighterFlagsRed,
        'fighterFlagsBlue': fighterFlagsBlue,
        'fighterLinksRed': fighterLinksRed,
        'fighterLinksBlue': fighterLinksBlue,
        'fighterBodyshotsRed': fighterBodyshotsRed,
        'fighterBodyshotsBlue': fighterBodyshotsBlue,
        'fighterHistoryRed': fighterHistoryRed,
        'fighterHistoryBlue': fighterHistoryBlue,
        'liveFightId': liveFightId,
        'liveFightOrder': liveFightOrder,
        'liveRoundNumber': liveRoundNumber,
        //'fighterHeadshotsRed': fighterHeadshotsRed,
        //'fighterHeadshotsBlue': fighterHeadshotsBlue
      };
      return sandbox;
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          // While waiting for data, display a circular progress indicator.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: primary,
              appBar: SuckMyBar(
                  title: widget.eventNameSelection,
                  title2: widget.eventDateSelection),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(widget.eventType,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: const SizedBox(
                              height: 50,
                            )),
                      ),
                      Skeletonizer(
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                  color: background),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 200,
                                    width: 70,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                const Expanded(
                                    child: SizedBox(
                                  height: 1,
                                )),
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'KESHBOY:) VS MAKHACHEV',
                                      style: mainEventTitle,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'LIGHTWEIGHT TITLE BOUT',
                                      style: mainEventDivision,
                                      textAlign: TextAlign.center,
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'MAIN EVENT',
                                          style: mainEventTag,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Text('-340',
                                                style: fighterTextSmall),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text('ODDS', style: darkGreyTiny),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text('+270',
                                                style: fighterTextSmall)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Expanded(
                                    child: SizedBox(
                                  height: 1,
                                )),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 200,
                                    width: 70,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ]))),
                      for (int i = 0; i < 7; i++)
                        Skeletonizer(
                            child: Column(
                          children: [
                            SizedBox(
                              height: i == 0 ? 30 : 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/fighter.png',
                                      height: 50,
                                    ),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 1,
                                  )),
                                  Column(
                                    children: [
                                      Text(
                                        'KESHBOY:) VS MAKHACHEV',
                                        style: titleBlack,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'LIGHTWEIGHT BOUT',
                                        style: fighterTextSmallGrey,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    height: 1,
                                  )),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/fighter.png',
                                      height: 50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))
                    ],
                  ),
                ),
              ),
            );
          } // If there was an error fetching data, display an error message.

          else if (snapshot.hasError) {
            print(snapshot.error);
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: primary,
              appBar: SuckMyBar(
                  title: widget.eventNameSelection,
                  title2: widget.eventDateSelection),
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(widget.eventType,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: const SizedBox(
                              height: 50,
                            )),
                      ),
                      Skeletonizer(
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                  color: background),
                              child: Row(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 200,
                                    width: 70,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                const Expanded(
                                    child: SizedBox(
                                  height: 1,
                                )),
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'KESHBOY:) VS MAKHACHEV',
                                      style: mainEventTitle,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'LIGHTWEIGHT TITLE BOUT',
                                      style: mainEventDivision,
                                      textAlign: TextAlign.center,
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'MAIN EVENT',
                                          style: mainEventTag,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Text('-340',
                                                style: fighterTextSmall),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text('ODDS', style: darkGreyTiny),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text('+270',
                                                style: fighterTextSmall)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Expanded(
                                    child: SizedBox(
                                  height: 1,
                                )),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 200,
                                    width: 70,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ]))),
                      for (int i = 0; i < 7; i++)
                        Stack(
                          children: [
                            Skeletonizer(
                                child: Column(
                              children: [
                                SizedBox(
                                  height: i == 0 ? 30 : 15,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: background,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/images/fighter.png',
                                          height: 50,
                                        ),
                                      ),
                                      const Expanded(
                                          child: SizedBox(
                                        height: 1,
                                      )),
                                      Column(
                                        children: [
                                          Text(
                                            'KESHBOY:) VS MAKHACHEV',
                                            style: titleBlack,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'LIGHTWEIGHT BOUT',
                                            style: fighterTextSmallGrey,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      ),
                                      const Expanded(
                                          child: SizedBox(
                                        height: 1,
                                      )),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/images/fighter.png',
                                          height: 50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            );
          } else {
            final Map<String, dynamic> sand = snapshot.data!;

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: SuckMyBar(
                  title: widget.eventNameSelection,
                  title2: widget.eventDateSelection),
              backgroundColor: primary,
              body: Column(
                children: [
                  /*
                  ValueListenableBuilder<int?>(
                      valueListenable: liveFightNotifier,
                      builder: (context, value, child) {
                        return Text(
                          value.toString(),
                          style: subtitleSecondary,
                        );
                      }),*/
                  const SizedBox(
                    height: 7.5,
                  ),
                  Text(widget.eventType,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                      )),
                  Row(
                    children: [
                      AnimatedBuilder(
                          animation: Listenable.merge(
                              [_translationController, _rotationController]),
                          builder: (context, child) {
                            double translateX = (_translationController.value *
                                    (screenWidth - _imageWidth))
                                .clamp(0, screenWidth - _imageWidth);

                            return Row(
                              children: [
                                SizedBox(
                                  width: translateX,
                                ),
                                RotationTransition(
                                  turns: _rotationAnimation,
                                  child: Image.asset(
                                    'assets/images/punch2.gif',
                                    width: 50,
                                  ),
                                ),
                              ],
                            );
                          }),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              if (_pageController.hasClients) {
                                if (_pageController.page == 0) {
                                  _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut);
                                } else {
                                  _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut);
                                }
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                ValueListenableBuilder<int>(
                                  valueListenable: _currentPageNotifier,
                                  builder: (context, value, child) {
                                    return Text(
                                      value == 0 ? 'CHAT' : 'FIGHT',
                                      style: chatText,
                                    );
                                  },
                                ),
                                RotationTransition(
                                  turns: _rotationAnimation,
                                  child: Icon(
                                    Icons.arrow_right_rounded,
                                    color: secondary,
                                    size: 50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    color: secondary,
                    thickness: 0.5,
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  Expanded(
                    // width: screenWidth - 15,
                    // height: screenHeight / 1.5,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: ListView.builder(
                                    cacheExtent: 2000,
                                    itemCount: sand['cardLength'],
                                    itemBuilder: (context, index) {
                                      return FightBoks(
                                        index: index,
                                        maincardLength: sand['maincardL'],
                                        prelimsLength: sand['prelimsL'],
                                        weightclass: sand['weightclass'],
                                        fighterNamesRed:
                                            sand['fighterNamesRed'],
                                        fighterNamesBlue:
                                            sand['fighterNamesBlue'],
                                        lastNamesRed: sand['lastNamesRed'],
                                        lastNamesBlue: sand['lastNamesBlue'],
                                        countriesBlue:
                                            sand['fighterCountriesBlue'],
                                        countriesRed:
                                            sand['fighterCountriesRed'],
                                        oddsRed: sand['fighterOddsRed'],
                                        oddsBlue: sand['fighterOddsBlue'],
                                        flagsRed: sand['fighterFlagsRed'],
                                        flagsBlue: sand['fighterFlagsBlue'],
                                        historyRed: sand['fighterHistoryRed'],
                                        historyBlue: sand['fighterHistoryBlue'],
                                        linksRed: sand['fighterLinksRed'],
                                        linksBlue: sand['fighterLinksBlue'],
                                        bodyshotsRed:
                                            sand['fighterBodyshotsRed'],
                                        bodyshotsBlue:
                                            sand['fighterBodyshotsBlue'],
                                      );
                                    },
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Chat(eventName: widget.eventNameSelection),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
