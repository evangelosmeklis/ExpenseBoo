import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedYear: Int
    @State private var showFullYear = true

    init() {
        _selectedYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }

    var availableYears: [Int] {
        let years = dataManager.getAvailableYears()
        return years.isEmpty ? [Calendar.current.component(.year, from: Date())] : years
    }

    var filteredStats: [MonthlyStats] {
        let allStats = dataManager.getMonthlyStats(for: selectedYear)
        if showFullYear {
            return allStats
        } else {
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())

            if selectedYear == currentYear {
                return Array(allStats.prefix(currentMonth))
            } else {
                return allStats
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Year Picker and Toggle
                VStack(spacing: 16) {
                    HStack {
                        Text("Year:")
                            .font(.headline)

                        Spacer()

                        Picker("Year", selection: $selectedYear) {
                            ForEach(availableYears, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Toggle(isOn: $showFullYear) {
                        Text(showFullYear ? "Showing full year" : "Showing up to current month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Stats List
                List {
                    ForEach(filteredStats) { monthStats in
                        MonthlyStatsRowView(stats: monthStats)
                    }
                }
            }
            .navigationTitle("Stats")
        }
        .onAppear {
            if !availableYears.contains(selectedYear) && !availableYears.isEmpty {
                selectedYear = availableYears.first!
            }
        }
    }
}

struct MonthlyStatsRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let stats: MonthlyStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stats.monthName)
                    .font(.headline)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("P/L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dataManager.currencySymbol)\(stats.profitLoss, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(stats.profitLoss >= 0 ? .green : .red)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text("\(dataManager.currencySymbol)\(stats.income, specifier: "%.2f")")
                            .foregroundColor(.green)
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)

                    Label {
                        Text("\(dataManager.currencySymbol)\(stats.expenses, specifier: "%.2f")")
                            .foregroundColor(.red)
                    } icon: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .font(.subheadline)

                    if stats.investments > 0 {
                        Label {
                            Text("\(dataManager.currencySymbol)\(stats.investments, specifier: "%.2f")")
                                .foregroundColor(.purple)
                        } icon: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.purple)
                        }
                        .font(.subheadline)
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StatsView()
        .environmentObject(DataManager())
}