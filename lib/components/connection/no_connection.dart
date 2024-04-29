import 'package:flutter/material.dart';
import 'package:mma_talk/components/styles.dart';

class NoConnection extends StatefulWidget {
  const NoConnection(
      {super.key,
      required this.width,
      required this.isLoading,
      required this.checkConnectivity});

  @override
  State<NoConnection> createState() => _NoConnectionState();
  final double width;

  final bool isLoading;
  final Function() checkConnectivity;
}

class _NoConnectionState extends State<NoConnection> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 85,
      left: 10,
      right: 10,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        elevation: 10,
        child: Container(
          width: widget.width - 15,
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: accent),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "No Internet Connection",
                style: subtitleSecondary,
              ),
              GestureDetector(
                onTap: widget.checkConnectivity,
                child: widget.isLoading
                    ? CircularProgressIndicator(
                        color: secondary,
                      )
                    : Text(
                        'RETRY',
                        style: boldSecondary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
