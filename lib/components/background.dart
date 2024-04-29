import 'package:flutter/material.dart';

class BackgroundPattern extends StatelessWidget {
  final Widget child;
  final double opacity;

  const BackgroundPattern(
      {Key? key, required this.child, required this.opacity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              opacity: opacity,
              fit: BoxFit.cover,
              image: const AssetImage(
                'assets/images/pattern.jpg',
              ))),
      child: child,
    );
  }
}
