//
//  ContentView.swift
//  ExpenseBoo
//
//  Created by Evangelos Meklis on 3/8/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)

            ExpensesView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("P/L")
                }
                .tag(1)

            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
