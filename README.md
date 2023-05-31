# ppg_core - PushPushGo Core SDK for iOS
![GitHub tag (latest)](https://img.shields.io/github/v/tag/ppgco/ppg-core-ios-sdk?style=flat-square)
[![Discord](https://img.shields.io/discord/1108358192339095662?color=%237289DA&label=Discord&style=flat-square)](https://discord.gg/NVpUWvreZa)
<!-- ![GitHub Workflow Status (main)](https://img.shields.io/github/actions/workflow/status/ppgco/ppg-core-ios-sdk/publish.yml?branch=main&style=flat-square) -->

Packages are published on pub.dev with same version as github releases tags

## Supported platforms:
 - iOS
 - Android

## Requirements:
Access to Apple Developer Account.
Access to HMS/FCM Developer Account.

## Product Info
PushPushGo Core* is a building block for push notifications:
 - sender for push notifications - we handle batch requests, aggregate feedback events and inform your webhook
 - images storage & traffic - we handle, crop and serve your push images
 - fast implementation - we cover ios, iOS, Web with push notifications support
 - you own your database and credentials - no vendor lock-in - we provide infrastructure, sdk & support
 - simple API - we provide one API for all providers

Contact: support+core@pushpushgo.com or [Discord](https://discord.gg/NVpUWvreZa)

<sub>PushPushGo Core is not the same as PushPushGo product - if you are looking for [PushPushGo - Push Notifications Management Platform](https://pushpushgo.com)</sub>

## How it works

IMAGE HERE

When you send request to our API to send message, we prepare images and then connect to different providers. 

When message is delieverd to the device and interacts with user, we collect events and pass them to our API.

After a short time you will recieve package with events on your webhook:

```json
{
    "messages": [
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "sent"
            },
            "ts": 1685009020243
        },
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "delivered"
            },
            "ts": 1685009020564
        }
    ]
}
```

Using that data you can calculate statistics or do some of your business logic.

## Environment setup
Make sure that you have flutter installed, and `flutter doctor` command pass.

```bash
$ flutter doctor
```

If pass without any exceptions you are ready to go through next steps

TIP: To create new flutter app please use command:
```bash
flutter create --org com.example --platforms="ios,android" -a kotlin -i swift demo_app
```

# 1. Add SDK to your existing application
## 1.1 Modify your `pubspec.yaml` file
```yaml
Add to `dependencies` section:
  ppg_core: ^0.0.3
```

## 1.2 Add code to your `main.dart` file
### 1.2.1 Import library
```dart
import 'package:ppg_core/ppg_core.dart';
```

### 1.2.1 Initialize client and run
```dart
  final _ppgCorePlugin = PpgCore();

  @override
  void initState() {
    super.initState();
    initializePpgCore();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initializePpgCore() async {
    // TBD Logic
    _ppgCorePlugin.initialize(onToken: (tokenJSON) {
      // Upload this token to your server backend - you need this to use our API to send push notifications to this user
      // This is a JSON formatted string contains all necessery informations to our backend.
      log(tokenJSON);
    });

    if (!mounted) return;

    _ppgCorePlugin.registerForNotifications();
  }
```

# 2. iOS Support
## 2.1 Specify platform in your podfile in `ios/` directory
```pod
platform :ios, '14.0'
```
## 2.2 Open XCode with `ios/` directory
```bash
$ xed ios/
```
### 2.2.1 Enable Push Notification Capabilities in Project Target
1. Select your root item in files tree called "**your_project_name**" with blue icon and select **your_project_name** in **Target** section.
2. Go to Signing & Capabilities tab and click on "**+ Capability**" under tabs.
3. Select **Push Notifications** and **Background Modes**
4. On **Background Modes** select items:
 - Remote notifications
 - Background fetch

### 2.2.2 Add NotificationServiceExtension
1. Go to file -> New -> Target
2. Search for **Notification Service Extension** and choose product name may be for example **NSE**
3. Finish process and on prompt about __Activate “NSE” scheme?__ click **Cancel**
4. Open file NotificationService.swift
5. Paste this code:
```swift
import UserNotifications
import PpgCoreSDK

class NotificationService: PpgCoreNotificationServiceExtension {
  
}
```
6. Add to previously used name **NSE** target to `Podfile`:
```
target 'NSE' do
  use_frameworks!
  use_modular_headers!
  pod 'PpgCoreSDK', '~> 0.0.8'
end
```

## 2.3 Try to run app and fetch Push Notifications token in debug console
```bash
$ flutter run
```

# 3. Android Support
## 3.1 Place your `google-services.json` file in `android/app` directory
## 3.2 Add to `android/app/src/main/res/values/` file names `ppgcore.xml` with content
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Required fields  -->
    <string name="default_fcm_project_id">Get_value_from_google-services.json</string> 
    <string name="default_hms_app_id">Get_value_from_hms_developer_account</string>
    <!-- Choose HMS or FCM - remove other one depends what platform you are use -->
    <drawable name="default_notification_icon">@drawable/ic_launcher_foreground</drawable>
    <!-- Optional fields -->
    <string name="default_channel_id">ppg_core_default</string>
    <string name="default_channel_name">PPG Core Default Channel</string>
    <bool name="default_channel_badge_enabled">true</bool>
    <bool name="default_channel_vibration_enabled">true</bool>
    <string-array name="default_vibration_pattern">0, 1000, 500, 1500, 1000</string-array>
    <bool name="default_channel_lights_enabled">true</bool>
    <color name="default_lights_color">#ff00ff</color>
    <string name="default_channel_sound">magic_tone</string>
</resources>
```

## 3.3 Try to run app and fetch Push Notifications token in debug console
```bash
$ flutter run
```

# Support & production run
If you need production credentials or just help with integration please visit us in [discord](https://discord.gg/NVpUWvreZa) or just mail to [support@pushpushgo.com](mailto:support@pushpushgo.com)