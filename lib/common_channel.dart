import 'package:flutter/services.dart';

class CommonChannel {
  static const String _channelName = 'com.pushpushgo/core';
  static const Duration _channelTimeout = Duration(seconds: 15);
  static const MethodChannel _channel = MethodChannel(_channelName);

  static void setMethodCallHandler(Future<dynamic> Function(MethodCall call) handler) {
    _channel.setMethodCallHandler(handler);
  }

  // From dart to native
  static Future<T?> invokeMethod<T>({
    required ChannelMethod method,
    dynamic arguments,
  }) {
    return _channel.invokeMethod<T>(method.name, arguments).timeout(_channelTimeout);
  }
}

enum ChannelMethod {
  initialize,
  registerForNotifications,
  unregisterFromNotifications,
  getToken,
  onLaunch,
  onMessage,
  onResume,
  onToken,
}

extension ChannelMethodExtensions on ChannelMethod {
  String get name {
    switch (this) {
      case ChannelMethod.initialize:
        return 'initialize';
      case ChannelMethod.registerForNotifications:
        return 'registerForNotifications';
      case ChannelMethod.unregisterFromNotifications:
        return 'unregisterFromNotifications';        
      case ChannelMethod.getToken:
        return 'getToken';
      case ChannelMethod.onLaunch:
        return 'onLaunch';
      case ChannelMethod.onMessage:
        return 'onMessage';
      case ChannelMethod.onResume:
        return 'onResume';
      case ChannelMethod.onToken:
        return 'onToken';
      default:
        return '';
    }
  }
}
