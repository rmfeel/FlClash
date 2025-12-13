import 'package:rmmy/enum/enum.dart';
import 'package:rmmy/models/models.dart';
import 'package:rmmy/state.dart';
import 'package:flutter/cupertino.dart';

class CommonPrint {
  static CommonPrint? _instance;

  CommonPrint._internal();

  factory CommonPrint() {
    _instance ??= CommonPrint._internal();
    return _instance!;
  }

  void log(String? text, {LogLevel logLevel = LogLevel.info}) {
    final payload = '[APP] $text';
    debugPrint(payload);
    if (!globalState.isInit) {
      return;
    }
    globalState.appController.addLog(
      Log.app(payload).copyWith(logLevel: logLevel),
    );
  }
}

final commonPrint = CommonPrint();
