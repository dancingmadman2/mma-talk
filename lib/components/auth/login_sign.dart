import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mma_talk/components/appbar.dart';
import 'package:mma_talk/components/auth/login.dart';
import 'package:mma_talk/components/auth/sign_up.dart';

import 'package:mma_talk/components/styles.dart';

class LoginSign extends StatefulWidget {
  const LoginSign({Key? key}) : super(key: key);

  @override
  State<LoginSign> createState() => _LoginSignState();
}

class _LoginSignState extends State<LoginSign> {
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  StreamSubscription<User?>? authSubscription;
  // final Stream<User?> authInstance = FirebaseAuth.instance.authStateChanges();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        // This will trigger a rebuild whenever the page changes
      });
    });
    authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    if (mounted) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: SuckMyBar(
          title: 'WELCOME TO MMA TALK',
          title2: _pageController.hasClients
              ? _pageController.page == 0
                  ? 'sign in'
                  : 'sign up'
              : '',
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: primary,
        body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              Login(
                pageController: _pageController,
              ),
              SignUp(
                pageController: _pageController,
              )
            ]));
  }
}
