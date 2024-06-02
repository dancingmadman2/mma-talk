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

import 'package:timezone/timezone.dart';

class EventBoxPast extends StatefulWidget {
  const EventBoxPast({super.key, required this.eventSelection});

  @override
  State<EventBoxPast> createState() => _EventBoxPastState();
  final int eventSelection;
}

class _EventBoxPastState extends State<EventBoxPast> {
  bool isLive = false;

  String currentDate = DateTime.now().toString().split(' ')[0];

  String imagePathRed = '';
  String imagePathBlue = '';

  Future<String> getLocalDateTime(
      String inputDateString, String localTimeZoneIdentifier) async {
    final inputDateFormat = DateFormat('y MMM dd hh:mm a zzz', 'en_US');
    final parsedDateTime = inputDateFormat.parse(inputDateString);

    final localTimeZone = getLocation(localTimeZoneIdentifier);
    final localDateTime = TZDateTime.from(parsedDateTime, localTimeZone);

    final localDateFormat = DateFormat.yMMMd().add_jm();
    return 'Local Date and Time: ${localDateFormat.format(localDateTime)}';
  }

  Future<Map<String, dynamic>> fetchPastEvents() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('de');
    await initializeDateFormatting('fr');
    await initializeDateFormatting('es');
    await initializeDateFormatting('it');
    await initializeDateFormatting('nl');

    String url = 'https://www.ufc.com/events#events-list-past';

    List<String> titles = [];
    List<String> eventTypes = [];
    List<String> datesP = [];
    List<String> dateTimes = [];
    List<String?> links = [];
    List<String?> undercards = [];
    List<String> headshotsRed = [];
    List<String> headshotsBlue = [];
    List<DateTime> processedDates = [];

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

      // kind of works for now...
      //final numberOfUpcomingEvents =
      //  document.querySelector('div.althelete-total');
/*
      int? toRemove =
          int.parse(numberOfUpcomingEvents!.text.toString().substring(0, 2)) -
              4;
*/
      const toRemove = 3;

      for (var element in eventDetails) {
        String text = element.text.replaceAll('\n', '').trim();
        String currentYear = currentDate.substring(0, 4);
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
            if (!imageUrl.contains('https')) {
              headshotsBlue.add('https://ufc.com$imageUrl');
            } else {
              headshotsBlue.add(imageUrl);
            }
          }
        }
      }

      titles.removeRange(0, toRemove);
      dateTimes.removeRange(0, toRemove);
      eventTypes.removeRange(0, toRemove);
      links.removeRange(0, toRemove);

      List<String> cards = List.generate(
          1, (index) => titles[index].replaceAll(RegExp(r'[0-9]'), ''));
      List<int> cardLengths = List.generate(
          1,
          (index) => undercards.indexWhere((label) =>
              label.toString().trim().contains(cards[index].trim())));
      headshotsRed.removeRange(0, cardLengths[0]);
      headshotsBlue.removeRange(0, cardLengths[0]);

      print(headshotsRed);
    } catch (e) {
      throw Exception(e);
    }
    return {
      'titles': titles,
      'links': links,
      'types': eventTypes,
      'dates': dateTimes,
      'undercards': undercards,
      'headshotsRed': headshotsRed,
      'headshotsBlue': headshotsBlue,
    };
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
        future: fetchPastEvents(),
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
            final Map<String, dynamic>? event = snapshot.data;

            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EventDetails(
                              isLive: false,
                              eventDateSelection: event?['dates']
                                  [widget.eventSelection],
                              eventLink: event?['links'][widget.eventSelection],
                              eventNameSelection: event?['titles']
                                  [widget.eventSelection],
                              eventType: event?['types'][widget.eventSelection],
                            )));
                  },
                  child: Container(
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
                              event?['titles'][widget.eventSelection],
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
                                        event?['types'][widget.eventSelection],
                                        style: eventTag,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        event?['dates'][widget.eventSelection],
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    event?['headshotsRed']
                                        [widget.eventSelection],
                                    height: 100,
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
                                  const Expanded(
                                    child: SizedBox(
                                      height: 1,
                                    ),
                                  ),
                                  Image.network(
                                    event?['headshotsBlue']
                                        [widget.eventSelection],
                                    height: 100,
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
                            ],
                          ),
                        ],
                      )),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            );
          }
        });
  }
}

String formatDateString(String inputString) {
  // Parse the input string into a DateTime object.
  final DateTime dateTime = DateFormat('MM-dd HH:mm').parse(inputString);

  // Format the DateTime object as "MMM d hh a" (e.g., "Sep 2 10 PM").
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
