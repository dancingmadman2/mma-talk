import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

User? get currentUser => _firebaseAuth.currentUser;

class Message {
  final String text;
  final String senderId;
  final int timestamp; // Unix timestamp
  final String username;

  Message({
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.username,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
      text: json['text'],
      username: json['username'],
      senderId: json['senderId'],
      timestamp: json['timestamp'],
    );
  }

  Map<dynamic, dynamic> toJson() => {
        'text': text,
        'username': username,
        'senderId': senderId,
        'timestamp': timestamp,
      };
}
