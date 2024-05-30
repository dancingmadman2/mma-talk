import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mma_talk/components/connection/network_controller.dart';

import 'package:mma_talk/components/styles.dart';

import '../mma/ufc_event_box.dart';
import '../mma/ufc_past_event_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

ValueNotifier<bool> stuckOnWaiting = ValueNotifier(false);

class _HomeScreenState extends State<HomeScreen> {
  final networkController = Get.find<NetworkController>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int selection = 0;
  int? selectedSegment = 0;

  String formattedDate = '';
  bool isLive = false;

  List<String> liveEventNames = [];

  List<Widget> upcomingEvents = List.generate(
      5,
      (index) => EventBox(
            eventSelection: index,
          ));

  ListView pastEvents = ListView.builder(
    cacheExtent: 800,
    itemCount: 4,
    itemBuilder: (context, index) {
      return EventBoxPast(eventSelection: index);
    },
  );

  Future<void> _handleRefresh() async {
    isLoading = true;

    //_checkConnectivity();
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (selection == 0) {
          upcomingEvents.clear();
          upcomingEvents = List.generate(
              5,
              (index) => EventBox(
                    eventSelection: index,
                  ));
          isLoading = false;
        } else {
          //pastEvents.clear();
          pastEvents = ListView.builder(
            cacheExtent: 800,
            itemCount: 4,
            itemBuilder: (context, index) {
              return EventBoxPast(eventSelection: index);
            },
          );
          isLoading = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        //bottomNavigationBar: const BottomNavBar(),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                splashColor: secondary,
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    selection = 0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'UPCOMING EVENTS',
                    style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: selection == 0 ? Colors.white : properGrey),
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: secondary,
                onTap: () {
                  setState(() {
                    selection = 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'PAST EVENTS',
                    style: GoogleFonts.bebasNeue(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: selection == 1 ? Colors.white : properGrey),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: primary,
          shadowColor: const Color.fromRGBO(0, 0, 0, 0),
        ),
        backgroundColor: primary,
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: primary,
          onRefresh: _handleRefresh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  //if (!error)
                  Visibility(
                    visible: selection == 0 ? true : false,
                    child: GetBuilder<NetworkController>(builder: (controller) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.77,
                          child: ListView(
                            children: upcomingEvents,
                          ));
                    }),
                  ),
                  // if (!error)
                  Visibility(
                    visible: selection == 1 ? true : false,
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.77,
                        child: ListView.builder(
                          cacheExtent: 800,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return EventBoxPast(eventSelection: index);
                          },
                        )),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
