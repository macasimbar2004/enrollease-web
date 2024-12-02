import 'package:flutter/material.dart';

class Nav {
  static void push(BuildContext context, Widget widget) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }

  static void pushReplace(BuildContext context, Widget widget) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }

  static void pop(BuildContext context, [Object? returnValue]) {
    Navigator.of(context).pop(returnValue);
  }
}
