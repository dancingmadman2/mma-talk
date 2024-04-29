// ignore_for_file: unused_import

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:mma_talk/components/appbar.dart';
import 'package:mma_talk/components/auth/login_sign.dart';
import 'package:mma_talk/components/chat/bottom_sheet.dart';
import 'package:mma_talk/components/chat/message.dart';
import 'package:mma_talk/components/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mma_talk/components/auth/auth.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.eventName});
  final String eventName;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();

  User? currentUser;

  StreamSubscription<User?>? authSubscription;
  FirebaseDatabase database = FirebaseDatabase.instance;
  bool isLoading = false;
  late final DatabaseReference _messagesRef;

  final List<Message> _messages = [];

  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user
        ?.uid; // This will return the UID of the logged-in user or null if no user is logged in
  }

  Future<String?> fetchUsername(String userId) async {
    String? userId = getCurrentUserId();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users/$userId/username');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      return event.snapshot.value as String?;
    }
    return null;
  }

  void _sendMessage() async {
    final userId = getCurrentUserId();

    if (userId != null) {
      final username = await fetchUsername(userId);

      if (username != null) {
        final text = _controller.text;
        if (text.isNotEmpty) {
          final int timestamp = DateTime.now().millisecondsSinceEpoch;
          // Ensure this is an int
          _messagesRef.push().set(Message(
                text: text,
                senderId: userId,
                username: username,
                timestamp: timestamp,
              ).toJson());

          if (mounted) {
            _controller.clear();
          }
        }
      }
    }
  }

  String formatDuration(Duration duration) {
    if (duration.inDays > 365) {
      int years = duration.inDays ~/ 365;
      return '$years years ago';
    } else if (duration.inDays > 30) {
      int months = duration.inDays ~/ 30;
      return '$months months ago';
    } else if (duration.inDays > 0) {
      return '${duration.inDays} days ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours ago';
    } else if (duration.inMinutes > 0) {
      if (duration.inMinutes <= 1) {
        return '${duration.inMinutes} minute ago';
      } else {
        return '${duration.inMinutes} minutes ago';
      }
    } else {
      return 'Just now';
    }
  }

  void _onMessageAdded(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value is Map<dynamic, dynamic>) {
      if (mounted) {
        setState(() {
          // Reverse the _messages list and add new message at the end
          _messages.insert(
              0, Message.fromJson(value)); // Add new message at the beginning
          //_messages.add(Message.fromJson(value));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize _messagesRef here using widget.eventName
    _messagesRef =
        FirebaseDatabase.instance.ref('messages/${widget.eventName}');

    _messagesRef.onChildAdded.listen(_onMessageAdded);

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
      authSubscription?.cancel(); // Cancel the subscription
      _controller.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        width: screenWidth - 15,
                        decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(8)),
                        child: Material(
                            borderRadius: BorderRadius.circular(8),
                            elevation: 4,
                            color: background,
                            child: TextFormField(
                              cursorColor: Colors.black,
                              controller: _controller,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              textAlignVertical: TextAlignVertical.center,
                              style: chatInput,
                              onFieldSubmitted: (value) {
                                _sendMessage();
                              },
                              maxLength: 50,
                              maxLines: 2,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'SEND MESSAGE',
                                hintStyle: hintOswald,
                                counterStyle: counterChat,
                                prefixIcon: const Icon(
                                  CupertinoIcons.chat_bubble_text,
                                  size: 30,
                                ),
                              ),
                            ))),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: secondary,
                    ),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          Container(
              decoration: BoxDecoration(
                  color: background, borderRadius: BorderRadius.circular(8)),
              height: screenHeight * .44,
              child: ListView.builder(
                //reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                      message.timestamp); // Correct conversion here

                  final formattedTime = DateFormat('hh:mm a')
                      .format(dateTime); // Format the DateTime object

                  Duration timeAgo = DateTime.now().difference(dateTime);

                  String formattedTimeAgo = formatDuration(timeAgo);

                  return Column(
                    children: <Widget>[
                      ListTile(
                        //tileColor: background,

                        title: Text(
                          message.username,
                          style: username,
                        ), // Display the username
                        subtitle: Text(
                          message.text,
                          style: chatInput,
                        ),
                        trailing: Text(
                          'TIME: $formattedTime\n $formattedTimeAgo',
                          style: time,
                        ), // Display the formatted time here
                      ),
                      const Divider(height: 1, thickness: 1),
                    ],
                  );
                },
              )),
          const SizedBox(
            height: 15,
          ),
          if (currentUser == null)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginSign()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'SIGN IN TO SEND MESSAGES',
                    style: chatText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
