import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:mma_talk/components/connection/dependeny_injection.dart';

import 'package:mma_talk/mma/more.dart';
import 'package:mma_talk/mma/ufc_rankings.dart';
import 'components/styles.dart';
import 'firebase_options.dart';
import 'package:mma_talk/home/home_screen.dart';

import 'mma/search.dart';

void main() async {
  runApp(
    const Main(),
  );
  DependencyInjection.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const Rankings(),
    const Search(),
    const More()
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: primary,
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    return GetMaterialApp(
      home: Scaffold(

         
          body: _screens.elementAt(selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 30,
            type: BottomNavigationBarType.fixed,
            backgroundColor: primary,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.calendar),
                label: 'FIGHTS',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_fill),
                label: 'RANKINGS',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: 'SEARCH',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: 'MORE')
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: properGrey,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            unselectedLabelStyle: navUnselected,
            selectedLabelStyle: navSelected,
            onTap: _onTappedBar,
          )),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      selectedIndex = value;
    });
  }
}
