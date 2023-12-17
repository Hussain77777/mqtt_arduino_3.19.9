import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';



class AppUtils {
  static void showflushBar(String msg, BuildContext context) {
    showFlushbar(
        context: context,
        flushbar: Flushbar(
          backgroundColor: Color(0xFF2A3C51),
          forwardAnimationCurve: Curves.decelerate,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(15),
          message: msg,
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          reverseAnimationCurve: Curves.easeInOut,
          positionOffset: 20,
          icon: const Icon(
            Icons.info,
            size: 18,
            color: Colors.white,
          ),
        )..show(context));
  }

  static bool isEmailValidate(String? email) {
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(email!)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isPasswordValidate(String? password) {
    bool isValidPassword = password!.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*()_+]'));
    if (isValidPassword == true) {
      return false;
    } else {
      return true;
    }
  }
}
