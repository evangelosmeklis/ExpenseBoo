import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }
    
    func scheduleDaily(at time: Date, dataManager: DataManager) {
        guard dataManager.settings.notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "ExpenseBoo Daily Update"
        content.sound = .default
        
        let balance = dataManager.getCurrentBalance()

        if balance >= 0 {
            content.body = "Great job! You have \(dataManager.currencySymbol)\(String(format: "%.2f", balance)) left this month."
        } else {
            content.body = "You're \(dataManager.currencySymbol)\(String(format: "%.2f", abs(balance))) over budget this month. Consider reviewing your expenses."
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_update", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            }
        }
    }
    
    
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateNotifications(dataManager: DataManager) {
        cancelAllNotifications()

        if dataManager.settings.notificationsEnabled {
            scheduleDaily(at: dataManager.settings.dailyNotificationTime, dataManager: dataManager)
        }
    }
}