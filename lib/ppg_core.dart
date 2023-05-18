import 'dart:async';

import 'package:ppg_core/common_channel.dart';
import 'package:flutter/services.dart';

typedef MessageHandler = Function(Map<String, dynamic> message);
typedef SubscriptionHandler = Function(String serializedJSON);

enum RegisterStatus {
  granted,
  denied,
}

class PpgCore {
  String? lastSubscriptionJSON;

  MessageHandler _onMessage = (_) {};
  SubscriptionHandler _onToken = (_) {
    throw UnsupportedError("onToken handler must be declared");
  };

  Future<void> initialize({
    required SubscriptionHandler onToken,
    MessageHandler? onMessage,
  }) {
    _onMessage = onMessage ?? (_) {};
    _onToken = onToken;

    CommonChannel.setMethodCallHandler(_handleChannelMethodCallback);
    return CommonChannel.invokeMethod<void>(
      method: ChannelMethod.initialize,
    ).catchError(
      (error) {
        if (error is! TimeoutException) throw error;
      },
    );
  }

  /// Registers for iOS push notifications | android notifications also
  Future<RegisterStatus> registerForNotifications() async {
    String result = await CommonChannel.invokeMethod<String>(
          method: ChannelMethod.registerForNotifications,
        ) ??
        "undefined";

    if (result == "granted") {
      return RegisterStatus.granted;
    }

    return RegisterStatus.denied;
  }

  /// Returns the push token.
  Future<String?> getToken() async {
    return CommonChannel.invokeMethod<String>(
      method: ChannelMethod.getToken,
    );
  }

  // From native to dart
  Future<dynamic> _handleChannelMethodCallback(MethodCall call) async {
    String method = call.method;

    dynamic arguments = call.arguments;
    if (method == ChannelMethod.onMessage.name) {
      return _onMessage(arguments ?? "{}"); //.cast<String, dynamic>()
    } else if (method == ChannelMethod.onToken.name) {
      lastSubscriptionJSON = arguments;
      return _onToken(lastSubscriptionJSON ?? "{}");
    }
    throw UnsupportedError("Unrecognized JSON message");
  }
}
