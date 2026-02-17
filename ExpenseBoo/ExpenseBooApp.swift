//
//  ExpenseBooApp.swift
//  ExpenseBoo
//
//  Created by Evangelos Meklis on 3/8/25.
//

import SwiftUI

@main
struct ExpenseBooApp: App {
    @StateObject private var dataManager = DataManager()
    private let notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .onAppear {
                    notificationManager.requestPermission()
                    dataManager.addSubscriptionExpenses()
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
                .onChange(of: dataManager.settings.notificationsEnabled) { oldValue, newValue in
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
                .onChange(of: dataManager.settings.dailyNotificationTime) { oldValue, newValue in
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
                .onChange(of: dataManager.expenses) { oldValue, newValue in
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
                .onChange(of: dataManager.incomes) { oldValue, newValue in
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
        }
    }
}
