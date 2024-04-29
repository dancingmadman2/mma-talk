import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/styles.dart';

class Rankings extends StatefulWidget {
  const Rankings({super.key});

  @override
  State<Rankings> createState() => _RankingsState();
}

class _RankingsState extends State<Rankings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rankings // in development',
              style: filter,
            ),
            const Icon(
              CupertinoIcons.hammer,
              color: Colors.white,
              size: 35,
            )
          ],
        ),
      ),
    );
  }
}
