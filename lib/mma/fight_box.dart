import 'package:flutter/material.dart';
import 'package:mma_talk/components/clip.dart';
import 'package:mma_talk/components/styles.dart';
import 'package:mma_talk/mma/ufc_event_details.dart';

import 'package:mma_talk/mma/ufc_fight_details.dart';
import 'package:mma_talk/mma/ufc_fighter_card.dart';

class FightBoks extends StatefulWidget {
  const FightBoks(
      {super.key,
      required this.index,
      required this.maincardLength,
      required this.prelimsLength,
      required this.weightclass,
      required this.fighterNamesRed,
      required this.fighterNamesBlue,
      required this.lastNamesRed,
      required this.lastNamesBlue,
      required this.oddsRed,
      required this.oddsBlue,
      required this.bodyshotsRed,
      required this.bodyshotsBlue,
      required this.flagsRed,
      required this.flagsBlue,
      required this.countriesRed,
      required this.countriesBlue,
      required this.linksRed,
      required this.linksBlue,
      required this.historyRed,
      required this.historyBlue});

  @override
  State<FightBoks> createState() => _FightBoksState();
  final int index;
  final int maincardLength;
  final int prelimsLength;
  final List<String> weightclass;
  final List<String> fighterNamesRed;
  final List<String> fighterNamesBlue;
  final List<String> lastNamesRed;
  final List<String> lastNamesBlue;
  final List<String> oddsRed;
  final List<String> oddsBlue;
  final List<String> bodyshotsRed;
  final List<String> bodyshotsBlue;
  final List<String> flagsRed;
  final List<String> flagsBlue;
  final List<String> countriesRed;
  final List<String> countriesBlue;
  final List<String> linksRed;
  final List<String> linksBlue;
  final List<bool> historyRed;
  final List<bool> historyBlue;
}

class _FightBoksState extends State<FightBoks> {
  final shadowRed =
      'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_RED.png?VersionId=0NwYm4ow5ym9PWjgcpd05ObDBIC5pBtX&itok=woJQm5ZH';
  final shadowBlue =
      'https://dmxg5wxfqgb4u.cloudfront.net/styles/event_fight_card_upper_body_of_standing_athlete/s3/image/fighter_images/SHADOW_Fighter_fullLength_BLUE.png?VersionId=1Jeml9w1QwZqmMUJDg8qTrTk7fFhqUra&itok=fiyOmUkc';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Column(
          children: [
            if (widget.index == 0)
              Column(
                children: [
                  Text(
                    'MAIN CARD',
                    style: maincard,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            if (widget.index == widget.maincardLength &&
                widget.maincardLength != 0)
              Column(
                children: [
                  Text(
                    'PRELIMS',
                    style: maincard,
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            if (widget.index == widget.prelimsLength + widget.maincardLength &&
                widget.prelimsLength != 0)
              Column(
                children: [
                  Text(
                    'EARLY PRELIMS',
                    style: maincard,
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ValueListenableBuilder<int?>(
                valueListenable: liveFightNotifier,
                builder: (context, value, child) {
                  return value == widget.index
                      ? Text(
                          'LIVE',
                          style: live,
                        )
                      : const SizedBox();
                }),
            Material(
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
              child: Container(
                width: screenWidth - 15,
                // height: i == 0 ? 110 : null,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.weightclass[widget.index],
                      style: fighterTextSmallGrey,
                      textAlign: TextAlign.center,
                    ),
                    Align(
                      //heightFactor: 0.8,

                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FightDetails(
                                                    fightWeightclass:
                                                        widget.weightclass[
                                                            widget.index],
                                                    fighterBlueName:
                                                        widget.fighterNamesBlue[
                                                            widget.index],
                                                    fighterBlueOdd: widget
                                                        .oddsBlue[widget.index],
                                                    fighterRedName:
                                                        widget.fighterNamesRed[
                                                            widget.index],
                                                    fighterRedOdd: widget
                                                        .oddsRed[widget.index],
                                                    fighterBlueLastName:
                                                        widget.lastNamesBlue[
                                                            widget.index],
                                                    fighterRedLastName:
                                                        widget.lastNamesRed[
                                                            widget.index],
                                                    fighterBlueBodyshot:
                                                        widget.bodyshotsBlue[
                                                            widget.index],
                                                    fighterRedBodyshot:
                                                        widget.bodyshotsRed[
                                                            widget.index],
                                                    fighterBlueLink:
                                                        widget.linksBlue[
                                                            widget.index],
                                                    fighterRedLink: widget
                                                        .linksRed[widget.index],
                                                    fighterRedFlag: widget
                                                        .flagsRed[widget.index],
                                                    fighterBlueFlag:
                                                        widget.flagsBlue[
                                                            widget.index],
                                                    fighterRedCountry:
                                                        widget.countriesRed[
                                                            widget.index],
                                                    fighterBlueCountry:
                                                        widget.countriesBlue[
                                                            widget.index],
                                                  )));
                                    },
                                    child: Text(
                                      '${widget.lastNamesRed[widget.index]}  \nVS \n${widget.lastNamesBlue[widget.index]}',
                                      style: widget.index == 0
                                          ? mainTitleBlack
                                          : titleBlack,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => FighterDetails(
                                            fighterBodyshot: widget
                                                .bodyshotsRed[widget.index],
                                            fighterName: widget
                                                .fighterNamesRed[widget.index],
                                            fighterCountry: widget
                                                .countriesRed[widget.index],
                                            fighterFlag:
                                                widget.flagsRed[widget.index],
                                            fighterLink:
                                                widget.linksRed[widget.index],
                                          )));
                                },
                                child: Stack(
                                  children: [
                                    //if (!error)
                                    Align(
                                      heightFactor: 0.2,
                                      widthFactor: 1.2,
                                      child: Transform(
                                        transform: Matrix4.translationValues(
                                            0, 105, 0),
                                        child: ClipRect(
                                          clipper: ClipFromBottom(),
                                          child: Image.network(
                                            widget.bodyshotsRed[widget.index],
                                            height: 300,
                                            fit: BoxFit.fitHeight,
                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              return Image.asset(
                                                  height: 300,
                                                  fit: BoxFit.fitHeight,
                                                  'assets/images/shadow_red.png');
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
                                        ),
                                      ),
                                    ),
                                    if (widget.historyRed[widget.index])
                                      Positioned(
                                        left: 5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: properRed,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                'WIN',
                                                style: winLose,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                child: SizedBox(
                                  height: 1,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => FighterDetails(
                                            fighterBodyshot: widget
                                                .bodyshotsBlue[widget.index],
                                            fighterName: widget
                                                .fighterNamesBlue[widget.index],
                                            fighterCountry: widget
                                                .countriesBlue[widget.index],
                                            fighterFlag:
                                                widget.flagsBlue[widget.index],
                                            fighterLink:
                                                widget.linksBlue[widget.index],
                                          )));
                                },
                                child: Stack(
                                  children: [
                                    //if (!error)
                                    Align(
                                      heightFactor: 0.2,
                                      widthFactor: 1.2,
                                      child: Transform(
                                        transform: Matrix4.translationValues(
                                            0, 105, 0),
                                        child: ClipRect(
                                          clipper: ClipFromBottom(),
                                          child: Image.network(
                                            widget.bodyshotsBlue[widget.index],
                                            height: 300,
                                            fit: BoxFit.fitHeight,

                                            errorBuilder: (BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace) {
                                              return Image.asset(
                                                  height: 300,
                                                  fit: BoxFit.fitHeight,
                                                  'assets/images/shadow_blue.png');
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
                                        ),
                                      ),
                                    ),
                                    if (widget.historyBlue[widget.index])
                                      Positioned(
                                        right: 5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: properRed,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                'WIN',
                                                style: winLose,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      shadowColor: background,
                      elevation: 5,
                      //borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.oddsRed[widget.index],
                                    style: fighterTextSmall,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'ODDS',
                                    style: fighterTextSmallBoldGrey,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.oddsBlue[widget.index],
                                    style: fighterTextSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.network(
                                widget.flagsRed[widget.index],
                                width: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center();
                                },
                              ),
                              Text(
                                widget.countriesRed[widget.index],
                                style: fighterTextSmaller,
                              ),
                              const Spacer(),
                              Text(
                                widget.countriesBlue[widget.index],
                                style: fighterTextSmaller,
                              ),
                              Image.network(
                                widget.flagsBlue[widget.index],
                                width: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: widget.index == 0 ? 30 : 15,
            ),
          ],
        ),
      ],
    );
  }
}
