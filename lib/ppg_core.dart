import 'dart:async';
import 'package:ppg_core/common_channel.dart';
import 'package:flutter/services.dart';

typedef MessageHandler = Function(Map<String, dynamic> message);
typedef ExternalDataHandler = Function(String data);
typedef SubscriptionHandler = Function(String serializedJSON);
typedef DefaultLabels = List<String>;
typedef PpgCoreOptions = Map<String, dynamic>;

enum RegisterStatus {
  granted,
  denied,
  prompt,
}

class PpgCore {
  String? lastSubscriptionJSON;
  
  // ignore: prefer_function_declarations_over_variables
  final MessageHandler _onMessage = (_) {};
  // ignore: prefer_function_declarations_over_variables
  final ExternalDataHandler _onExternalData = (_) {};
  
  SubscriptionHandler _onToken = (_) {
    throw UnsupportedError("onToken handler must be declared");
  };

  Future<void> initialize({
    required SubscriptionHandler onToken,
    // MessageHandler? onMessage,
    // ExternalDataHandler? onExternalData,
    List<String>? iosLabels,
  }) {
    // _onMessage = onMessage ?? (_) {};
    // _onExternalData = onExternalData ?? (_) {};
    _onToken = onToken;

    final List<String> defaultIosLabels = ["Open", "Show more"];
    final List<String> assignedLabels = iosLabels ?? [];

    String firstLabel = assignedLabels.isNotEmpty ? assignedLabels[0] : defaultIosLabels[0];
    String secondLabel = assignedLabels.length > 1 ? assignedLabels[1] : defaultIosLabels[1];

    CommonChannel.setMethodCallHandler(_handleChannelMethodCallback);
    
    final PpgCoreOptions opts = {
      'iosLabels': [firstLabel, secondLabel]
    };

    return CommonChannel.invokeMethod<void>(
      method: ChannelMethod.initialize,
      arguments: opts
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
    } else if (method == ChannelMethod.onExternalData.name) {
      return _onExternalData(arguments ?? "");
    }

    throw UnsupportedError("Unrecognized message");
  }
}
