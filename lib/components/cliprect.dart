import 'package:flutter/material.dart';

class MyCustomClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Define the rectangle to clip the image
    return Rect.fromPoints(
      const Offset(
          50, 0), // Start clipping from x = 50 (50 pixels from the left)
      Offset(size.width, size.height), // Clip to the bottom-right corner
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
