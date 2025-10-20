import 'dart:io' show Platform;

import 'package:flutter/services.dart';

class NativeTimezone {
  static const MethodChannel _channel = MethodChannel('app/timezone');

  static Future<String> getLocalTimezone() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return 'UTC';
    }
    try {
      final result = await _channel.invokeMethod<String>('getLocalTimezone');
      if (result == null || result.isEmpty) return 'UTC';
      return result;
    } catch (_) {
      return 'UTC';
    }
  }
}

