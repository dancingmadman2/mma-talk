import 'dart:async';

import 'package:flutter/material.dart';

import 'package:html/parser.dart' as html_parser;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:mma_talk/components/styles.dart';
import 'package:http/http.dart' as http;

import 'package:mma_talk/mma/ufc_event_details.dart';

import 'package:skeletonizer/skeletonizer.dart';
import '../components/translations.dart';

import 'package:timezone/data/latest.dart' as tzdata;
import 'package:mma_talk/home/home_screen.dart';

//import 'package:timezone/timezone.dart';

class EventBox extends StatefulWidget {
  const EventBox({
    super.key,
    required this.eventSelection,
  });

  @override
  State<EventBox> createState() => _EventBoxState();

  final int eventSelection;
}

class _EventBoxState extends State<EventBox> with TickerProviderStateMixin {
  late AnimationController _resizableController =
      AnimationController(vsync: this);

  @override
  void initState() {
    _resizableController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );
    _resizableController.addStatusListener((animationStatus) {
      switch (animationStatus) {
        case AnimationStatus.completed:
          _resizableController.reverse();
          break;
        case AnimationStatus.dismissed:
          _resizableController.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _resizableController.forward();
    super.initState();
    tzdata.initializeTimeZones();
  }

  @override
  void dispose() {
    _resizableController.dispose();

    super.dispose();
  }

  bool isLive = false;

  String currentDate = DateTime.now().toString().split(' ')[0];

  String imagePathRed = '';
  String imagePathBlue = '';

  String formatDateString(String inputString) {
    // Parse the input string into a DateTime object.
    final DateTime dateTime = DateFormat('MM-dd HH:mm').parse(inputString);

    // Format the DateTime ("Sep 2 10 PM").
    String formattedString = DateFormat('MMM d / hh:mm a').format(dateTime);

    // formattedString = '$formattedString / Main Card';

    return formattedString;
  }

  String replaceWords(String input, Map<String, String> translations) {
    String result = input;

    translations.forEach((oldWord, newWord) {
      result = result.replaceAll(oldWord, newWord);
    });

    return result;
  }

  Future<Map<String, dynamic>> fetchEvents() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
    await initializeDateFormatting('fr');
    await initializeDateFormatting('es');
    await initializeDateFormatting('it');
    await initializeDateFormatting('nl');

    String url = 'https://www.ufc.com/events#events-list-upcoming';

    List<String> titles = [];
    List<String> eventTypes = [];
    List<String> datesP = [];
    List<String> dateTimes = [];
    List<String?> links = [];
    List<String?> undercards = [];
    List<String> headshotsRed = [];
    List<String> headshotsBlue = [];
    List<DateTime> processedDates = [];
    DateTime currentDatex = DateTime.now();
    try {
      final response = await http.get(Uri.parse(url));
      final document = html_parser.parse(response.body);

      final eventNames =
          document.querySelectorAll('.c-card-event--result__headline');
      final eventLinks = document.querySelectorAll(
          'div.c-card-event--result__info h3.c-card-event--result__headline');
      final eventDetails =
          document.querySelectorAll('.c-card-event--result__date');
      final eventUndercards = document.querySelectorAll('.fight-card-tickets');
      final imgElementsBlue =
          document.querySelectorAll('div.field--name-blue-corner');
      final imgElementsRed =
          document.querySelectorAll('div.field--name-red-corner');

      final logoElement =
          document.querySelectorAll('.c-card-event--result__logo a');

      //final numberOfUpcomingEvents =
      //  document.querySelector('div.althelete-total');
/*
      int? toRemove =
          int.parse(numberOfUpcomingEvents!.text.toString().substring(0, 2)) -
              4;
*/
      const toRemove = 4;

      titles = eventNames.map((element) => element.text).toList();

      links = eventLinks
          .map((h3Element) => h3Element.querySelector('a')?.attributes['href'])
          .where((hrefAttributeValue) => hrefAttributeValue != null)
          .toList();

      for (final anchorElement in logoElement) {
        final href = anchorElement.attributes['href'];
        if (href != null) {
          if (href.contains('night')) {
            eventTypes.add('UFC FIGHT NIGHT');
          } else {
            String x = href.toString().substring(7);
            x = x.replaceAll('-', ' ');
            eventTypes.add(x);
          }
        }
      }

      undercards = eventUndercards
          .map((element) => element.attributes['data-fight-label'])
          .where((fightLabel) => fightLabel != null)
          .toList();

      for (var imageElement in imgElementsRed) {
        final image = imageElement.querySelector('img');
        final imageUrl = image?.attributes['src'];

        if (imageUrl != null) {
          final lowerCaseImageUrl = imageUrl.toLowerCase();
          if (lowerCaseImageUrl.contains('themes') ||
              lowerCaseImageUrl.contains('silhouette')) {
            headshotsRed.add('https://i.ibb.co/QvP2m4r/question-mark.png');
          } else {
            if (!headshotsRed.contains(imageUrl)) {
              if (!imageUrl.contains('https')) {
                headshotsRed.add('https://ufc.com$imageUrl');
              } else {
                headshotsRed.add(imageUrl);
              }
            }
          }
        }
      }

      for (var imageElement in imgElementsBlue) {
        final image = imageElement.querySelector('img');
        final imageUrl = image?.attributes['src'];

        if (imageUrl != null) {
          final lowerCaseImageUrl = imageUrl.toLowerCase();
          if (lowerCaseImageUrl.contains('themes') ||
              lowerCaseImageUrl.contains('silhouette')) {
            headshotsBlue.add('https://i.ibb.co/QvP2m4r/question-mark.png');
          } else {
            if (!headshotsBlue.contains(imageUrl)) {
              if (!imageUrl.contains('https')) {
                headshotsBlue.add('https://ufc.com$imageUrl');
              } else {
                headshotsBlue.add(imageUrl);
              }
            }
          }
        }
      }

      for (var element in eventDetails) {
        String text = element.text.replaceAll('\n', '').trim();
        int currentYear = DateTime.now().year;
        //String currentYear = currentDate.substring(0, 4);
        String eventDate = text
            .substring(4, 27)
            .replaceAll('.', '')
            .replaceAll('/', '')
            .trim();

        eventDate = '$currentYear $eventDate'.trim().replaceAll('  ', ' ');

        eventDate = replaceWords(eventDate, languageMonthTranslations);
        datesP.add(eventDate);
      }

      for (String eventDate in datesP) {
        DateTime parsedEventDateTimeZone =
            DateFormat('yyyy MMM d hh:mm a Z').parse(eventDate);

        if (eventDate.contains('EDT')) {
          parsedEventDateTimeZone =
              parsedEventDateTimeZone.add(const Duration(hours: 7));
        } else if (eventDate.contains('EST')) {
          parsedEventDateTimeZone =
              parsedEventDateTimeZone.add(const Duration(hours: 8));
        }

        processedDates.add(parsedEventDateTimeZone);

        String eventDateString =
            parsedEventDateTimeZone.toString().substring(5, 16);
        String formattedDateString = formatDateString(eventDateString);

        dateTimes.add(formattedDateString);
      }

      if (processedDates.isNotEmpty &&
          currentDatex.isAfter(processedDates[widget.eventSelection])) {
        isLive = true;
      }

      /*
      List<int> cardLengths = List.generate(
          5,
          (index) => undercards.indexWhere(
              (label) => label.toString().trim() == cards[index].trim()));*/

      int numberOfEvents = 4;

      List<String> cards = List.generate(numberOfEvents,
          (index) => titles[index].replaceAll(RegExp(r'[0-9]'), ''));

      List<int> cardLengths = List.generate(numberOfEvents, (index) {
        final cardValue = cards[index].trim();

        final undercardIndex = undercards
            .indexWhere((label) => label.toString().trim().contains(cardValue));
        //Lewis vs Nascimento Ferreira

        if (undercardIndex == -1) {
          return 0; // skip the comparison if both are "TBD"
        } else {
          return undercardIndex;
        }
      });

      print(cards);

      //print(cardLengths);

      List<int> lengths = [];
      List<int> lengthsPast = [];

      List<String> titlesPast = List.from(titles);
      List<String> dateTimesPast = List.from(dateTimes);
      List<String> eventTypesPast = List.from(eventTypes);
      List<String> linksPast = List.from(links);
      List<String> headshotsRedPast = List.from(headshotsRed);
      List<String> headshotsBluePast = List.from(headshotsBlue);

      titlesPast.removeRange(0, toRemove);
      dateTimesPast.removeRange(0, toRemove);
      eventTypesPast.removeRange(0, toRemove);
      linksPast.removeRange(0, toRemove);

      List<String> cardsPast = List.generate(
          4, (index) => titlesPast[index].replaceAll(RegExp(r'[0-9]'), ''));
      List<int> cardLengthsPast = List.generate(
          4,
          (index) => undercards.indexWhere((label) =>
              label.toString().trim().contains(cardsPast[index].trim())));
      try {
        print(cardLengthsPast[0]);
        print(cardLengthsPast);
        headshotsRedPast.removeRange(0, cardLengthsPast[0]);
        headshotsBluePast.removeRange(0, cardLengthsPast[0]);
      } catch (e) {
        print('YARRAK: $e');
      }

      for (int i = 0; i < cardLengths.length - 1; i++) {
        lengths.add(cardLengths[i + 1] - cardLengths[i]);
      }
      print(lengths);
      for (int i = 0; i < cardLengthsPast.length - 1; i++) {
        lengthsPast.add(cardLengthsPast[i + 1] - cardLengthsPast[i]);
      }
      Map<int, List<int>> imagePathMap = {};
      try {
        imagePathMap = Map.fromEntries(
          List.generate(
              numberOfEvents,
              (index) =>
                  MapEntry(index, [cardLengths[index], cardLengths[index]])),
        );
      } catch (e) {
        print('anan: $e');
      }

      final defaultImagePath = [cardLengths[2], cardLengths[2]];

      final imagePath = imagePathMap[widget.eventSelection] ?? defaultImagePath;

      imagePathRed = widget.eventSelection != 0 && imagePath[0] == 0
          ? 'https://i.ibb.co/QvP2m4r/question-mark.png'
          : headshotsRed[imagePath[0]];
      imagePathBlue = widget.eventSelection != 0 && imagePath[0] == 0
          ? 'https://i.ibb.co/QvP2m4r/question-mark.png'
          : headshotsBlue[imagePath[1]];

      Map<String, dynamic> eventbox = {
        'titles': titles,
        'titlesPast': titlesPast,
        'links': links,
        'linksPast': linksPast,
        'types': eventTypes,
        'typesPast': eventTypesPast,
        'dates': dateTimes,
        'datesPast': dateTimesPast,
        'cardLengths': lengths,
        'cardLengthsPast': lengthsPast,
        'headshotsRed': headshotsRed,
        'headshotsBlue': headshotsBlue,
        'headshotsRedPast': headshotsRedPast,
        'headshotsBluePast': headshotsBluePast
      };
      return eventbox;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for data, display a circular progress indicator.
            return Skeletonizer(
                child: Column(
              children: [
                Container(
                    width: screenWidth - 15,
                    decoration: BoxDecoration(
                      color: background,

                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(width: 1, color: properGrey)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          child: Text(
                            'ALMEIDA VS LEWIS',
                            style: eventTitleBlack,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: eventTag,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: fighterTextSmallGrey,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: fighterTextSmallGrey,
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 100,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 100,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ));
          } else if (snapshot.hasError) {
            print('error: ${snapshot.error}');

            stuckOnWaiting.value = true;

            // If there was an error fetching data, display an error message.
            return Skeletonizer(
                child: Column(
              children: [
                Container(
                    width: screenWidth - 15,
                    decoration: BoxDecoration(
                      color: background,

                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(width: 1, color: properGrey)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          child: Text(
                            'ALMEIDA VS LEWIS',
                            style: eventTitleBlack,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: eventTag,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: fighterTextSmallGrey,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'UFC FIGHT NIGHT',
                                      style: fighterTextSmallGrey,
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 100,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fighter.png',
                                    height: 100,
                                    width: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
              ],
            ));
          } else {
            final Map<String, dynamic>? eventData = snapshot.data;

            return Column(
              children: [
                if (isLive && widget.eventSelection == 0)
                  Column(
                    children: [
                      Text(
                        'LIVE NOW',
                        style: live,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventDetails(
                                isLive: isLive,
                                eventDateSelection: eventData?['dates']
                                    [widget.eventSelection],
                                eventLink: eventData?['links']
                                    [widget.eventSelection],
                                eventNameSelection: eventData?['titles']
                                    [widget.eventSelection],
                                eventType: eventData?['types']
                                    [widget.eventSelection],
                              )));
                    },
                    child: AnimatedBuilder(
                        animation: _resizableController,
                        builder: (context, child) {
                          return Container(
                              width: screenWidth - 15,
                              decoration: BoxDecoration(
                                color: background,
                                border: isLive && widget.eventSelection == 0
                                    ? Border.all(
                                        color: properRed,
                                        width: _resizableController.value * 10)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    child: Text(
                                      eventData?['titles']
                                          [widget.eventSelection],
                                      style: eventTitleBlack,
                                      textAlign: TextAlign.center,
                                    ),
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
                                                eventData?['types']
                                                    [widget.eventSelection],
                                                style: eventTag,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                eventData!['dates']
                                                    [widget.eventSelection],
                                                style: eventTimeGrey,
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                'MAIN CARD',
                                                style: fighterTextSmallGrey,
                                              ),
                                              const SizedBox(
                                                height: 1,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (imagePathRed != '')
                                            Image.network(
                                              imagePathRed,
                                              height: 100,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                error = true;
                                                return const Center();
                                              }, // or any other widget to indicate an error
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child; // Image is fully loaded.
                                                }
                                                return const CircularProgressIndicator(
                                                  color: Colors.black,
                                                ); // Display a loading spinner.
                                              },
                                            ),
                                          const Expanded(
                                            child: SizedBox(
                                              height: 1,
                                            ),
                                          ),
                                          if (imagePathBlue != '')
                                            Image.network(
                                              imagePathBlue,
                                              height: 100,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                error = true;
                                                return const Center();
                                              }, // or any other widget to indicate an error
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
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
                                    ],
                                  ),
                                ],
                              ));
                        })),
                SizedBox(
                  height: isLive && widget.eventSelection == 0 ? 40 : 20,
                ),
              ],
            );
          }
        });
  }
}
