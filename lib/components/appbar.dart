import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mma_talk/components/styles.dart';

class SuckMyBar extends StatelessWidget implements PreferredSizeWidget {
  const SuckMyBar({
    Key? key,
    this.height = kToolbarHeight,
    required this.title,
    required this.title2,
  }) : super(key: key);

  final double height;
  final String title;
  final String title2;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //height: preferredSize.height,

      backgroundColor: primary,

      leading: IconButton(
        icon: const Icon(
          CupertinoIcons.arrow_left,
          color: Colors.white,
        ),
        onPressed: () {
          // Define your custom back button behavior here.
          Navigator.of(context).pop();
        },
      ),
      title: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: appBarTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 2.5,
          ),
          Text(
            title2,
            style: appBarTitle2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),

      centerTitle: true,
    );
  }
}