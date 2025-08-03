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
                    notificationManager.updateNotifications(dataManager: dataManager)
                    dataManager.addSubscriptionExpenses()
                }
                .onChange(of: dataManager.settings.notificationsEnabled) {
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
                .onChange(of: dataManager.settings.dailyNotificationTime) {
                    notificationManager.updateNotifications(dataManager: dataManager)
                }
        }
    }
}
