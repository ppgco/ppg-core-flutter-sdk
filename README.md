# **CORE** _by PushPushGo_ SDK for Flutter
![GitHub tag (latest)](https://img.shields.io/github/v/tag/ppgco/ppg-core-flutter-sdk?style=flat-square)
[![Discord](https://img.shields.io/discord/1108358192339095662?color=%237289DA&label=Discord&style=flat-square)](https://discord.gg/NVpUWvreZa)
<!-- ![GitHub Workflow Status (main)](https://img.shields.io/github/actions/workflow/status/ppgco/ppg-core-ios-sdk/publish.yml?branch=main&style=flat-square) -->

<small>Packages are published on pub.dev with same version as github releases tags</small>
## Product Info

**CORE** _by PushPushGo_ is a hassle-free building block for all your web and mobile push needs.

Send your transactional and bulk messages, and we'll take care of the rest.

#### What we offer:
 - Ready SDK for client/server integration - we have SDK for the most popular platforms.
 - Mobile and WebPush implementation (APNS, FCM, VAPID).
 - Transactional and bulk push notifications through API.
 - Hassle-free usage. Our servers handle traffic peaks and store images.
 - Event aggregation in bulk sent to your webhook for easy analysis or running your business logic.
 - GDPR-ready solution protecting private data in accordance with EU regulations.
 - No vendor lock-in - build and own your subscriber base (stateless solution).

#### What you get:
 - Cost-effective solution: pay for sent pushes, not for infrastructure, traffic, and storage.
 - Save time and effort on developing the sender and infrastructure.
 - Simple API interface for all channels with bulk support.
 - Support on our [Discord Server](https://discord.gg/NVpUWvreZa).
 - You can implement notification features your way.

#### Try it if:
 - You want to control the flow in your transactional messages and add a push notification channel.
 - You're looking for an easy push notifications tool for your organization, whether it's finance, e-commerce, online publishing, or any other sector.
 - You work in a software house and build solutions for your clients.
 - You want a hassle-free solution to focus on other tasks at hand.
 - You want to implement an on-premise solution for sending notifications.
 - You have issues with an in-house solution.
 - You're looking for a reliable provider and cooperation based on your needs.

## How it works

When client register for notifications you will get object with:
 - Credentials
 - Token/endpoint
 - Type of provider
 - Identifier of provider

We call this **Recipient** - it's your subscription data, store it in your database.

When you try to send message you will prepare:

 - **Bucket** - your temporary credentials bucket - this bucket can be reused any time, or recreated when credentials changed,

 - **Context** - your message - this context can be reused to send bulk messages or just used once when you send transactional message then is context is **temporary**

When you send message you will _authorize_ via **bucket** data, prepare message with **context** and send to **recipients** that can be bulked up to 1000 per request.

On the server side:
 - We validate and prepare the message body.
 - Then, we upload and resize images to our CDN.
 - Next, we connect and send to different providers.

On the client side:
 - Get notifications via our SDK in your App/Website.
 - When interacting with a notification, we collect events with our API.

On the server side:
 - We aggregate events and deliver them in bulk to your webhook endpoint.

### Architecture

![image](https://i.ibb.co/tst39rS/architecture.png "Architecture")

When a message is delivered to the device and interacts with the user, we collect events and pass them to our API. The collected events are resent to your webhook endpoint.

#### Webhooks events
During the journey of push we will trigger webhook events.

| Push Type    | Event      | Foreground | Background |
|---------|------------|------------|------------|
| Data    |            |            |            |
|         | delivered  | ✓          | ✓          |
|         | clicked    | ✓          | ✓          |
|         | sent       | ✓          | ✓          |
|         | close      | ✓          | ✓          |
| Silent<sup>1</sup>  |            |            |            |
|         | delivered  | ✓          | ✓          |
|         | sent       | ✓          | ✓          |

<small><sup>1</sup> - webpush doesn't support silent messages due to Push API implementation</small>

If `foreignId` field was passed with `receiver` then it will also be included in event in message.

Example events package:

```json
{
    "messages": [
        {
            "messageId": "8e3075f1-6b21-425a-bb4f-eeaf0eac93a2",
            "foreignId": "my_id",
            "result": {
                "kind": "delivered"
            },
            "ts": 1685009020243
        }
    ]
}
```

## Pricing

We charge $0.50 USD for every 1000 sent notifications.

## Support & Sales

Join our [Discord](https://discord.gg/NVpUWvreZa) to get support, your api key, talk or just keep an eye on it.

<sub>**CORE** _by PushPushGo_ is not the same as our main **PushPushGo** product - are you looking for [PushPushGo - Push Notifications Management Platform?](https://pushpushgo.com)</sub>

## Client side SDK - supported platforms / providers

| Platform | Provider | SDK        |
|----------|----------|------------|
| Android / Huawei  | FCM / HMS      | [CORE Android SDK](https://github.com/ppgco/ppg-core-android-sdk) |
| iOS | APNS      | [CORE iOS SDK](https://github.com/ppgco/ppg-core-ios-sdk) |
| Flutter | FCM / HMS / APNS      | [CORE Flutter SDK](https://github.com/ppgco/ppg-core-flutter-sdk) |
| Web | Vapid (WebPush)     | [CORE JS SDK](https://github.com/ppgco/ppg-core-js-sdk) |

## Server side SDK (sending notifications)
| Platform | SDK      |
|----------|----------|
| JavaScript / TypeScript  | [CORE JS SDK](https://github.com/ppgco/ppg-core-js-sdk) | 
| .NET  | [WIP - ask](https://discord.gg/NVpUWvreZa) | 
| Java  | [WIP - ask](https://discord.gg/NVpUWvreZa) | 

# SDK Integration instructions

## Requirements:
Access to Apple Developer Account.
Access to HMS/FCM Developer Account.

## Environment setup
Make sure that you have flutter installed, and `flutter doctor` command pass.

```bash
$ flutter doctor
```

If pass without any exceptions you are ready to go through next steps

# 1. Add SDK to your existing application
## 1.1 Install flutter package
```bash
$ flutter pub add ppg_core
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
```sh
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
  pod 'PpgCoreSDK', '~> 0.0.11'
end
```
7. In `Info.plist` add folowing to enable deep linking in flutter
```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

## 2.3 Try to run app and fetch Push Notifications token in debug console
```bash
$ flutter run
```

# 2.4 (Optional) If you want to override endpoint , or create new notification channels please create `PpgCore.plist` file with content

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PpgCoreSDKEndpoint</key>
	<string>https://api-core.pushpushgo.com/v1</string>
	<key>PpgCoreChannels</key>
	<array>
		<dict>
			<key>name</key>
			<string>testing_channel</string>
			<key>sound</key>
			<string>Submarine.aiff</string>
			<key>actions</key>
			<array>
				<string>Reply</string>
			</array>
		</dict>
		<dict>
			<key>name</key>
			<string>testing_channel_nowy</string>
			<key>sound</key>
			<string>sub.caf</string>
			<key>actions</key>
			<array>
				<string>Open</string>
				<string>Show more</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

# 3. Android Support

## 3.1 Add to your root build.gradle jitpack if you don't have already
```groovy
// build.gradle (root) or settings.gradle (dependencyResolutionManagement)
allprojects {
    repositories {
        // jitpack
        maven { url 'https://jitpack.io' }
        // only when use hms
        maven { url 'https://developer.huawei.com/repo/' }
    }
}
```

### 3.1.1 Add classpath dependencies in root build.gradle file:

If you have already configured fcm - omit this step

#### 3.1.1.1 For FCM:
```
classpath 'com.google.gms:google-services:4.3.15'
```
#### 3.1.1.2 For HMS:
```
classpath 'com.huawei.agconnect:agcp:1.6.0.300'
```

## 3.2 Place your `google-services.json` file in `android/app` directory
## 3.3 Add to `android/app/src/main/res/values/` file names `ppgcore.xml` with content
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
## 3.4 Add to your `AndroidManifest.xml`

This file is placed in `android/app/src/main/`

### 3.4.1 Permissions (on root level)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<!-- If you want to support vibration -->
<uses-permission android:name="android.permission.VIBRATE"/>
```

### 3.4.2 Service (on application level)

Depends what provider you want to use please choose one of available options

#### 3.4.2.1 For FCM

```xml
<service
    android:name=".FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

and create file called `FirebaseMessagingService` with content:

```kotlin
import com.pushpushgo.core_sdk.sdk.fcm.FcmMessagingService  
  
class FirebaseMessagingService : FcmMessagingService() {}

```

#### 3.4.2.2 For HMS

```xml
<service
  android:name=".service.MyHmsMessagingService"
  android:exported="false">
  <intent-filter>
    <action android:name="com.huawei.push.action.MESSAGING_EVENT" />
  </intent-filter>
</service>
```

and create file called `MyHmsMessagingService` with content:

```kotlin

import com.pushpushgo.core_sdk.sdk.hms.HmsMessagingService  
  
class MyHmsMessagingService : HmsMessagingService() {}
```

### 3.4.3 Activities (on main activity level)
```xml
    <meta-data android:name="flutter_deeplinking_enabled" android:value="true" />

    <intent-filter  android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:host="com.example.packagename"
            android:scheme="app" />
        <data android:scheme="https" />
        <data android:scheme="http" />
    </intent-filter>

    <intent-filter>
        <action android:name="PUSH_CLICK" />
    </intent-filter>
```
## 3.4 Modify build.gradle and local.properties:

### 3.4.1 Add to `android/app/local.properties`:
```groovy
flutter.minSdkVersion=21
```

### 3.4.2 Add to `android/app/build.gradle`:
```groovy
def flutterMinSdkVersion = localProperties.getProperty('flutter.minSdkVersion')
if (flutterMinSdkVersion == null) {
    flutterMinSdkVersion = 21
}
```

### 3.4.3 Modify default config
Add minSdkVersion in defaultConfig for android:
```groovy
    defaultConfig {
        minSdkVersion flutterMinSdkVersion
    }
```

### 3.4.5 Add dependencies (app level) and apply plugin

#### 3.4.5.1 For FCM
```groovy
// build.gradle (:app)
dependencies {  
  ...  
  implementation "com.github.ppgco:ppg-core-android-sdk:0.0.33"
  implementation 'com.google.firebase:firebase-messaging-ktx:23.1.2'  
  implementation platform('com.google.firebase:firebase-bom:31.2.3')  
}
```

On top add **apply plugin**
```groovy
apply plugin: 'com.google.gms.google-services'
```

#### 3.4.5.2 For HMS

```groovy
dependencies {
  ...
  implementation 'com.github.ppgco:ppg-core-android-sdk:0.0.33'
  implementation 'com.huawei.agconnect:agconnect-core:1.7.2.300'  
  implementation 'com.huawei.hms:push:6.7.0.300'   
}
```

On top add **apply plugin**
Paste this below `com.android.library`
```groovy
apply plugin: 'com.huawei.agconnect'
```

## 3.4 Try to run app and fetch Push Notifications token in debug console
```bash
$ flutter run
```


# Sending notifications

## 1. iOS
### 1.1. Prepare certificates
 1. Go to [Apple Developer Portal - Identities](https://developer.apple.com/account/resources/identifiers/list) and go to **Identifiers** section
 2. Select from list your appBundleId like `com.example.your_project_name`
 3. Look for PushNotifications and click "**Configure**" button
 4. Select your __Certificate Singing Request__ file
 5. Download Certificates and open in KeyChain Access (double click in macos)
 6. Find this certificate in list select then in context menu (right click) select export and export to .p12 format file with password.
### 2. Prepare configuration
 1. Wrap exported certficates with Base64 with command
 ```bash
 $ cat Certificate.p12 | base64
 ```
 2. Prepare JSON with provider configuration
 ```json
{
    "type": "apns_cert",
    "payload": {
    "p12": "encoded base64 Certficiate.p12",
    "passphrase": "PASSWORD",
    "production": false,
    "appBundleId": "com.example.your_product_name",
}
 ```

## 2. Android
  1. Go to [Firebase Developer Console](https://console.firebase.google.com/)
  2. Select your project and go to **Settings**
  3. On **Service Accounts** section click **Generate Credentials**
  4. Prepare JSON with provider configuration
 ```json
{
    "type": "fcm_v1",
    "payload": {
       // Content of service account file
    }
}
 ```

## 3. Go to example [SenderSDK](https://github.com/ppgco/ppg-core-js-sdk/tree/main/examples/sender) docs 
 In examples please use prepared "providerConfig" and token returned from SDK to send notifications.

# Support & production run
All API keys available in this documentation allows you to test service with very low rate-limits.
If you need production credentials or just help with integration please visit us in [discord](https://discord.gg/NVpUWvreZa) or just mail to [support+core@pushpushgo.com](mailto:support+core@pushpushgo.com)
