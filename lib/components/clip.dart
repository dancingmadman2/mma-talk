import 'package:flutter/material.dart';

class ClipFromBottom extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // Define the rectangle to clip the image
    return Rect.fromPoints(
      Offset(
          0,
          size.height -
              170), // Start clipping from y = size.height - 50 (50 pixels from the bottom)
      Offset(size.width, 0), // Clip to the top-right corner
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
