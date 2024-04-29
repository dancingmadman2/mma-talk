import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mma_talk/components/styles.dart';

class NetworkController extends GetxController {
  var isConnected = false.obs; // Using Getx's reactive state
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void onInit() {
    super.onInit();

    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }

  @override
  void onClose() {
    connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> checkInitialConnectivity() async {
    var connectivityResult = await connectivity.checkConnectivity();
    updateConnectionStatus(connectivityResult);
  }

  void updateConnectionStatus(ConnectivityResult result) {
    isConnected.value =
        result != ConnectivityResult.none; // Update the observable variable
    if (result == ConnectivityResult.none) {
      Get.rawSnackbar(
          messageText: Text(
            'No internet connection detected',
            textAlign: TextAlign.center,
            style: subtitleSecondary,
          ),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: accent,
          borderRadius: 8,
          icon: Icon(
            Icons.wifi_off_rounded,
            color: secondary,
          ),
          margin: const EdgeInsets.only(bottom: 65),
          snackStyle: SnackStyle.GROUNDED);
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      update();
    }
  }
}
