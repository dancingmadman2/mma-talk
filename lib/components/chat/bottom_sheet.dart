import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mma_talk/components/chat/message.dart';
import 'package:mma_talk/components/styles.dart';

class BottomSheetContent extends StatefulWidget {
  const BottomSheetContent({super.key});

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;

  String? _username;

  // method to write username, email to firebase realtime database
  void addUsername(String username, String uid) async {
    setState(() {
      isLoading = true;
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");
    try {
      await ref.push().set({"username": username});
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success')),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String?> getUsername(String uid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users/$uid/username');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      return event.snapshot.value as String?;
    } else {
      return null; // Or handle the case where the username doesn't exist
    }
  }

  @override
  void initState() {
    if (currentUser != null) {
      _username = '${getUsername(currentUser!.uid)}';
    }

    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sheetWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight / 2 + 30,
      color: primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 15,
          ),
          Text(
            'Choose Username',
            style: subtitleSecondary,
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
              alignment: Alignment.topLeft,
              width: sheetWidth - 15,
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
            height: 15,
          ),
          SizedBox(
            width: sheetWidth - 15,
            height: 65,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: accent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: () {
                if (_usernameController.toString().isNotEmpty) {
                  addUsername(_usernameController.text, currentUser!.uid);
                } else {}
              },
              child: isLoading
                  ? CircularProgressIndicator(
                      color: secondary,
                    )
                  : Text(
                      'Confirm',
                      style: subtitle,
                    ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Welcome to FIGHT TALK\n please be respectful to other chatters.',
            textAlign: TextAlign.center,
            style: littleTitle,
          )
        ],
      ),
    );
  }
}
