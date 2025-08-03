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
        let savingsProgress = getSavingsProgressText(dataManager: dataManager)
        
        if balance >= 0 {
            content.body = "Great job! You have $\(String(format: "%.2f", balance)) left this month. \(savingsProgress)"
        } else {
            content.body = "You're $\(String(format: "%.2f", abs(balance))) over budget this month. Consider reviewing your expenses."
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
    
    func scheduleSavingGoalReminders(dataManager: DataManager) {
        guard dataManager.settings.notificationsEnabled else { return }
        
        let activeGoals = dataManager.savingGoals.filter { !$0.isGeneric && $0.targetDate >= Date() && $0.progress < 1.0 }
        
        for goal in activeGoals {
            let content = UNMutableNotificationContent()
            content.title = "Saving Goal Update"
            content.sound = .default
            
            let progressPercent = Int(goal.progress * 100)
            let daysLeft = goal.daysRemaining
            
            if daysLeft <= 7 {
                content.body = "Only \(daysLeft) days left for '\(goal.name)'! You're \(progressPercent)% there. Save $\(String(format: "%.2f", goal.dailySavingNeeded)) per day to reach your goal."
            } else if progressPercent < 25 && daysLeft <= 30 {
                content.body = "'\(goal.name)' needs attention! You're only \(progressPercent)% complete with \(daysLeft) days remaining."
            }
            
            if !content.body.isEmpty {
                let identifier = "goal_\(goal.id.uuidString)"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling goal notification: \(error)")
                    }
                }
            }
        }
    }
    
    private func getSavingsProgressText(dataManager: DataManager) -> String {
        if let genericGoal = dataManager.savingGoals.first(where: { $0.isGeneric }) {
            let currentSurplus = max(dataManager.getCurrentBalance(), 0)
            let progress = min(currentSurplus / genericGoal.targetAmount, 1.0)
            let progressPercent = Int(progress * 100)
            
            if progress >= 1.0 {
                return "You've reached your monthly saving goal! 🎉"
            } else {
                return "You're \(progressPercent)% towards your monthly saving goal."
            }
        }
        return ""
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateNotifications(dataManager: DataManager) {
        cancelAllNotifications()
        
        if dataManager.settings.notificationsEnabled {
            scheduleDaily(at: dataManager.settings.dailyNotificationTime, dataManager: dataManager)
            scheduleSavingGoalReminders(dataManager: dataManager)
        }
    }
}