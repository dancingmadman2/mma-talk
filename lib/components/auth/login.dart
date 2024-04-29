import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mma_talk/components/styles.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.pageController});
  final PageController pageController;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscureText = true;
  bool isLoggedIn = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  StreamSubscription<User?>? authSubscription;

  void setUser(String username, String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
    await ref.set({
      "username": username,
    });
  }

  Future<void> signIn(String email, String password, VoidCallback onSuccess,
      VoidCallback onError) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      onSuccess(); // Call the success callback
      setState(() {
        isLoggedIn = true;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')),
          );
        }
      } else if (e.code == 'wrong-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Wrong password provided for that user.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}')),
          );
        }
      }
    } catch (e) {
      // Show snackbar on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  /*
  Future<void> signOutGoogle() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}
  */

  Future<User?> signInWithGoogle(VoidCallback onSuccess) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null; // The user canceled the sign-in process
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google user's credentials
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    onSuccess();

    setState(() {
      isLoggedIn = true;
    });
    setUser(currentUser!.displayName.toString(), currentUser!.uid);

    return userCredential.user;
  }

  @override
  void initState() {
    super.initState();

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
    super.dispose();
    if (mounted) {
      _emailController.dispose();
      _passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset(
            'assets/images/kick_lock_grey.png',
            scale: 4,
          ),
          Container(
              alignment: Alignment.topCenter,
              child: Text(
                'Sign in',
                style: titleSecondary,
              )),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15),
              child: Text('Email', style: subtitleSecondary)),
          const SizedBox(
            height: 10,
          ),
          Container(
              alignment: Alignment.topLeft,
              width: screenWidth - 15,
              height: 65,
              decoration: BoxDecoration(
                  color: background, borderRadius: BorderRadius.circular(8)),
              child: Material(
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  color: background,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    textAlignVertical: TextAlignVertical.center,
                    style: inputPassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'EMAIL',
                      labelStyle: hintOswald,
                      prefixIcon: Icon(
                        CupertinoIcons.mail_solid,
                        color: accent,
                      ),
                      hintText: 'ENTER YOUR EMAIL',
                      hintStyle: hintOswald,
                    ),
                  ))),
          const SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15),
              child: Text('Password', style: subtitleSecondary)),
          const SizedBox(
            height: 10,
          ),
          Container(
              alignment: Alignment.topLeft,
              width: screenWidth - 15,
              height: 65,
              decoration: BoxDecoration(
                  color: background, borderRadius: BorderRadius.circular(8)),
              child: Material(
                  borderRadius: BorderRadius.circular(8),
                  elevation: 4,
                  color: background,
                  child: TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: _obscureText,
                    autofocus: false,
                    textAlignVertical: TextAlignVertical.center,
                    style: inputPassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'PASSWORD',
                      labelStyle: hintOswald,
                      prefixIcon: Icon(
                        CupertinoIcons.lock_fill,
                        color: accent,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: accent,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: 'ENTER YOUR PASSWORD',
                      hintStyle: hintOswald,
                    ),
                  ))),
          const SizedBox(
            height: 10,
          ),
          Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 15),
              child: Text(
                'Forgot Password?',
                style: littleTitleInteractive,
              )),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: screenWidth - 15,
            height: 65,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: accent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {
                if (_emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  signIn(
                      _emailController.text,
                      _passwordController.text,
                      () => Navigator.pop(context),
                      () => '' //print('Error during sign in'),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email or password is empty')),
                  );
                }
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      color: secondary,
                    )
                  : Text(
                      'Sign in',
                      style: subtitle,
                    ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(children: [
            Expanded(
                child: Divider(
              thickness: 1.5,
              color: secondary,
            )),
            const SizedBox(
              width: 5,
            ),
            Text("Or Continue with", style: littleTitle),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Divider(
              thickness: 1.5,
              color: secondary,
            )),
          ]),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  User? user = await signInWithGoogle(
                    () => Navigator.pop(context),
                  );
                  if (user != null) {
                    // User successfully signed in
                    // Navigate to your app's main screen
                  } else {
                    // User canceled or sign-in failed
                  }
                },
                child: Image.asset(
                  'assets/images/google.png',
                  height: 75,
                  width: 75,
                ),
              ),
              Image.asset(
                'assets/images/x.png',
                height: 75,
                width: 75,
              ),
              Image.asset(
                'assets/images/apple.png',
                height: 75,
                width: 75,
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    "Don't have an account?",
                    style: littleTitle,
                  )),
              GestureDetector(
                onTap: () {
                  if (widget.pageController.hasClients) {
                    widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut);
                  }
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.bebasNeue(
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: secondary)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
