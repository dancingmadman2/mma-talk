import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mma_talk/components/appbar_nav.dart';
import '../components/styles.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: const AppbarNav(
        title: 'MORE',
        title2: 'APP/ACCOUNT SETTINGS',
      ),
      body: Center(
        child: InkWell(
          onTap: () async {
            try {
              await signOut();
            } catch (e) {
              //print('Sign out error: $e');
            }
          },
          child: Container(
            decoration: BoxDecoration(color: accent),
            child: Text(
              'SIGN OUT',
              style: filter,
            ),
          ),
        ),
      ),
    );
  }
}
