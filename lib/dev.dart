import 'package:flutter/foundation.dart';

void dPrint(Object? obj) {
  if (kDebugMode) {
    debugPrint(obj.toString());
  }
}
