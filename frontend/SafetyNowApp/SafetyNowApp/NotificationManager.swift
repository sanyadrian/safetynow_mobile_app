import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func disableNotifications() {
        // Remove all delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // Optionally, inform your backend to stop sending notifications to this device.
    }
} 