import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toast {
  void toastMessage(
      {String? message, Color? bgColor, Color? textColor, double? textsize}) {
    Fluttertoast.showToast(
        msg: message!,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: bgColor,
        textColor: textColor,
        fontSize: textsize);
  }
}
