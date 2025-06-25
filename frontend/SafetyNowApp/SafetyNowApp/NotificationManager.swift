import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()

    func registerForPushNotifications() {
        print("🔄 Requesting notification permissions...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func disableNotifications() {
        // Remove all delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // Optionally, inform your backend to stop sending notifications to this device.
    }
    
    func registerDeviceTokenWithBackend(token: String) {
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            print("📱 Registering device token with backend...")
            NetworkService.shared.registerDeviceToken(token: token, accessToken: accessToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("✅ Device token registered successfully with backend")
                    case .failure(let error):
                        print("❌ Failed to register device token: \(error)")
                    }
                }
            }
        } else {
            print("⚠️ No access token available, device token not registered")
        }
    }
} 