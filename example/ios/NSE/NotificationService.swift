//
//  NotificationService.swift
//  NSE
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import UserNotifications
import PpgCoreSDK

class NotificationService: PpgCoreNotificationServiceExtension {
  override func getEndpoint() -> String {
    return "https://ppg-core.master1.qappg.co/v1"
  }
}
