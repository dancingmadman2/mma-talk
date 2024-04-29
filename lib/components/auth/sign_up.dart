import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mma_talk/components/styles.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.pageController});
  final PageController pageController;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  StreamSubscription<User?>? authSubscription;

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  // method to write username, email to firebase realtime database
  void setUser(String username, String email, String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
    await ref.set({
      "username": username,
      "email": email,
    });
  }

  // Sign Up with email username
  Future<void> signUp(String username, String email, String password,
      VoidCallback onSuccess, VoidCallback onError) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = currentUser?.uid ?? "";
      if (currentUser != null) {
        setUser(username, email, uid);
        print(currentUser?.displayName);
      }
      // await _auth.currentUser?.sendEmailVerification();
      onSuccess(); // Call the success callback
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The password provided is too weak.')),
          );
        }
      } else if (e.code == 'email-already-in-use') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('The account already exists for that email.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign Up failed: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // listen to auth state changes
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
      _usernameController.dispose();
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
                'Sign Up',
                style: titleSecondary,
              )),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15),
              child: Text('Username', style: subtitleSecondary)),
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
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    textAlignVertical: TextAlignVertical.center,
                    style: inputPassword,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'USERNAME',
                      labelStyle: hintOswald,
                      prefixIcon: Icon(
                        CupertinoIcons.person_fill,
                        color: accent,
                      ),
                      hintText: 'ENTER YOUR USERNAME',
                      hintStyle: hintOswald,
                    ),
                  ))),
          const SizedBox(
            height: 20,
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15),
              child: Text('EMAIL', style: subtitleSecondary)),
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
            height: 25,
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
                    _usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  signUp(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      () => Navigator.pop(context),
                      () => '' //print('Error during sign in'),
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all the fields')),
                  );
                }
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      color: secondary,
                    )
                  : Text(
                      'Sign Up',
                      style: subtitle,
                    ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    "Already have an account?",
                    style: littleTitle,
                  )),
              GestureDetector(
                onTap: () {
                  if (widget.pageController.hasClients) {
                    widget.pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut);
                  }
                },
                child: Text(
                  'Sign In',
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
