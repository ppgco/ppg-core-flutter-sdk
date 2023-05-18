import Flutter
import PpgCoreSDK
import UserNotifications

public class PpgCorePlugin: NSObject, FlutterPlugin, FlutterApplicationLifeCycleDelegate {
  // TODO: read plist?
  var ppgCoreClient: PpgCoreClient = PpgCoreClient(endpoint: "https://ppg-core.master1.qappg.co/v1")

  enum MethodIdentifier: String {
    case initialize
    case registerForNotifications
    case onMessage
    case onToken
  }
  
  private var channel: FlutterMethodChannel?

  static var instance: PpgCorePlugin?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.pushpushgo/core", binaryMessenger: registrar.messenger())
    let instance = PpgCorePlugin()
    
    PpgCorePlugin.instance = instance
    
    instance.channel = channel
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    PpgCoreLogger.info("registrar")
  }
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    return true
  }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = MethodIdentifier(rawValue: call.method)
    switch method {
    case .initialize:
        return onInitialize(callback: result)
    case .registerForNotifications:
        return onRegisterForNotifications(callback: result)
    default:
        return result(FlutterMethodNotImplemented)
    }
  }

  private func onInitialize(callback: @escaping FlutterResult) {
    // TODO: Pass dynamic data with "action labels" / define multiple channels
    UNUserNotificationCenter.current().delegate = PpgCorePlugin.instance
    ppgCoreClient.initialize(actionLabels: ["Open", "Check more"])
    return callback("success")
  }

  private func onRegisterForNotifications(callback: @escaping FlutterResult) {
    return ppgCoreClient.registerForNotifications(handler: {
          result in
          switch result {
          case .success:
              return callback("granted")
          case .error:
              return callback("denied")
          }
      })
  }

  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let subscriberJSON = Subscription(token: deviceToken).toJSONString();
    // PpgCoreLogger.info(subscriberJSON)
    channel?.invokeMethod(MethodIdentifier.onToken.rawValue, arguments: subscriberJSON)
  }

  public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
      PpgCoreLogger.info("didReceiveRemoteNotification")
      ppgCoreClient.handleBackgroundRemoteNotification(userInfo: userInfo, completionHandler: completionHandler)
      return true
  }

  // Works only on UIKit on SwiftUI it can be done onChange()
  public func applicationWillEnterForeground(_ application: UIApplication) {
      PpgCoreLogger.info("applicationWillEnterForeground")
      ppgCoreClient.resetBadge()
  }
  
  public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    PpgCoreLogger.info("didFailToRegisterForRemoteNotificationsWithError")
    PpgCoreLogger.info(error.localizedDescription)
    channel?.invokeMethod(MethodIdentifier.onToken.rawValue, arguments: "{\"error\": \(error.localizedDescription)}")
  }
  
  public func applicationDidBecomeActive(_ application: UIApplication) {
    PpgCoreLogger.info("applicationWillEnterForeground")
    ppgCoreClient.resetBadge()
  }

}

extension PpgCorePlugin: UNUserNotificationCenterDelegate {
  
  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      PpgCoreLogger.info("userNotificationCenter.willPresent")
      
      do {
          let jsonData = try JSONSerialization.data(withJSONObject: notification.request.content.userInfo, options: .prettyPrinted)
          if let jsonString = String(data: jsonData, encoding: .utf8) {
              channel?.invokeMethod(MethodIdentifier.onMessage.rawValue, arguments: jsonString)
              PpgCoreLogger.info(jsonString)
          }
      } catch {
          channel?.invokeMethod(MethodIdentifier.onMessage.rawValue, arguments: "Error converting dictionary to string: \(error)")
      }
      
      ppgCoreClient.handleNotification(notification: notification, completionHandler: completionHandler)
  }
  
  public func userNotificationCenter(_ center: UNUserNotificationCenter,
          didReceive response: UNNotificationResponse,
          withCompletionHandler completionHandler:
            @escaping () -> Void) {
      PpgCoreLogger.info("userNotificationCenter.didReceive")
      ppgCoreClient.handleNotificationResponse(response: response, completionHandler: completionHandler)
  }
  
  public func userNotificationCenter(_ center: UNUserNotificationCenter, didDismissNotification notification: UNNotification) {
      PpgCoreLogger.info("userNotificationCenter.didDismissNotification")
      ppgCoreClient.handleNotificationDismiss(notification: notification)
  }
}
