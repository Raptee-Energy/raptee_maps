import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void hideKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

void printMsg(String msg) {
  if (kDebugMode) {
    print(msg);
  }
}
