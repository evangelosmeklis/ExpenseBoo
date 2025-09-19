import SwiftUI

struct StatsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedYear: Int
    @State private var showFullYear = true
    @State private var selectedView = 0 // 0 = Monthly, 1 = Yearly Summary
    @State private var showingAddManualPL = false

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
                // View Picker
                Picker("View", selection: $selectedView) {
                    Text("Monthly Details").tag(0)
                    Text("Yearly Summary").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)

                // Year Picker
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
                .padding(.horizontal)

                if selectedView == 0 {
                    // Monthly View
                    VStack(spacing: 16) {
                        Toggle(isOn: $showFullYear) {
                            Text(showFullYear ? "Showing full year" : "Showing up to current month")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    // Stats List
                    List {
                        ForEach(filteredStats) { monthStats in
                            MonthlyStatsRowView(stats: monthStats, year: selectedYear)
                        }
                    }
                } else {
                    // Yearly Summary View
                    YearlyStatsView(year: selectedYear)
                }
            }
            .navigationTitle("Stats")
            .toolbar {
                if selectedView == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddManualPL = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddManualPL) {
                AddManualPLView(selectedYear: selectedYear)
            }
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
    let year: Int
    @State private var showingEditManualPL = false

    var isManualEntry: Bool {
        dataManager.getManualPL(for: stats.month, year: year) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stats.monthName)
                    .font(.headline)

                if isManualEntry {
                    Text("(Manual)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Text("P/L")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if hasNoData || isManualEntry {
                            Image(systemName: "pencil.circle")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    Text("\(dataManager.currencySymbol)\(stats.profitLoss, specifier: "%.2f")")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(stats.profitLoss >= 0 ? .green : .red)
                }
            }

            if !isManualEntry {
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
            } else {
                // Show breakdown for manual entries if they have income/expenses
                if stats.income > 0 || stats.expenses > 0 || stats.investments > 0 {
                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if stats.income > 0 {
                                Label {
                                    Text("\(dataManager.currencySymbol)\(stats.income, specifier: "%.2f")")
                                        .foregroundColor(.green)
                                } icon: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .font(.subheadline)
                            }

                            if stats.expenses > 0 {
                                Label {
                                    Text("\(dataManager.currencySymbol)\(stats.expenses, specifier: "%.2f")")
                                        .foregroundColor(.red)
                                } icon: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .font(.subheadline)
                            }

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

                            if stats.income > 0 || stats.expenses > 0 {
                                Text("Manual Breakdown")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if stats.investments > 0 {
                                Text("Manual Investment")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditManualPL = true
        }
        .contextMenu {
            Button(action: { showingEditManualPL = true }) {
                Label("Add/Edit Manual Entry", systemImage: "pencil")
            }
        }
        .sheet(isPresented: $showingEditManualPL) {
            AddManualPLView(selectedYear: year, selectedMonth: stats.month)
        }
    }

    private var hasNoData: Bool {
        stats.income == 0 && stats.expenses == 0 && stats.investments == 0 && stats.profitLoss == 0
    }
}

struct YearlyStatsView: View {
    @EnvironmentObject var dataManager: DataManager
    let year: Int

    var yearlyStats: YearlyStats {
        dataManager.getYearlyStats(for: year)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Total Income",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalIncome),
                        color: .green,
                        icon: "plus.circle.fill"
                    )

                    StatCard(
                        title: "Total Expenses",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalExpenses),
                        color: .red,
                        icon: "minus.circle.fill"
                    )

                    StatCard(
                        title: "Total Investments",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalInvestments),
                        color: .purple,
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    StatCard(
                        title: "Net P/L",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalProfitLoss),
                        color: yearlyStats.totalProfitLoss >= 0 ? .green : .red,
                        icon: yearlyStats.totalProfitLoss >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                    )
                }

                // Performance Metrics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance Metrics")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Average Monthly P/L:")
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.averageMonthlyPL))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(yearlyStats.averageMonthlyPL >= 0 ? .green : .red)
                        }

                        Divider()

                        HStack {
                            Text("Best Month:")
                                .font(.subheadline)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(yearlyStats.bestMonth)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.bestMonthPL))
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Worst Month:")
                                .font(.subheadline)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(yearlyStats.worstMonth)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.worstMonthPL))
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddManualPLView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss

    let selectedYear: Int
    var selectedMonth: Int?

    @State private var month: Int
    @State private var entryMode = 0 // 0 = Direct P/L, 1 = Separate Income/Expenses
    @State private var profitLoss: String = ""
    @State private var income: String = ""
    @State private var expenses: String = ""
    @State private var investments: String = ""
    @State private var note: String = ""

    init(selectedYear: Int, selectedMonth: Int? = nil) {
        self.selectedYear = selectedYear
        self.selectedMonth = selectedMonth
        self._month = State(initialValue: selectedMonth ?? Calendar.current.component(.month, from: Date()))
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: month)) ?? Date()
        return formatter.string(from: date)
    }

    var existingManualPL: ManualPL? {
        dataManager.getManualPL(for: month, year: selectedYear)
    }

    var isValidForm: Bool {
        if entryMode == 0 {
            // Direct P/L mode
            let hasValidPL = !profitLoss.isEmpty && Double(profitLoss) != nil
            let hasValidInvestment = investments.isEmpty || Double(investments) != nil
            return hasValidPL || (!investments.isEmpty && hasValidInvestment)
        } else {
            // Income/Expenses mode
            let hasValidIncome = income.isEmpty || Double(income) != nil
            let hasValidExpenses = expenses.isEmpty || Double(expenses) != nil
            let hasValidInvestment = investments.isEmpty || Double(investments) != nil
            let hasData = !income.isEmpty || !expenses.isEmpty || !investments.isEmpty
            return hasData && hasValidIncome && hasValidExpenses && hasValidInvestment
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                    Text(existingManualPL != nil ? "Edit Manual Entry" : "Add Manual Entry")
                        .font(.headline)
                    Spacer()
                    Button("Save") {
                        saveManualPL()
                    }
                    .disabled(!isValidForm)
                }
                .padding()

                Form {
                    Section(header: Text("Manual P/L & Investment Entry")) {
                        if selectedMonth == nil {
                            Picker("Month", selection: $month) {
                                Text("January").tag(1)
                                Text("February").tag(2)
                                Text("March").tag(3)
                                Text("April").tag(4)
                                Text("May").tag(5)
                                Text("June").tag(6)
                                Text("July").tag(7)
                                Text("August").tag(8)
                                Text("September").tag(9)
                                Text("October").tag(10)
                                Text("November").tag(11)
                                Text("December").tag(12)
                            }
                        } else {
                            HStack {
                                Text("Month")
                                Spacer()
                                Text(monthName)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Text("Year")
                            Spacer()
                            Text(String(selectedYear))
                                .foregroundColor(.secondary)
                        }

                        Picker("Entry Mode", selection: $entryMode) {
                            Text("Direct P/L").tag(0)
                            Text("Income & Expenses").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        if entryMode == 0 {
                            // Direct P/L Entry
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("P/L Amount", text: $profitLoss)
                                    .keyboardType(.numbersAndPunctuation)

                                HStack(spacing: 12) {
                                    Button("Set as Profit") {
                                        if let amount = Double(profitLoss.replacingOccurrences(of: "-", with: "")) {
                                            profitLoss = String(abs(amount))
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.green)

                                    Button("Set as Loss") {
                                        if let amount = Double(profitLoss.replacingOccurrences(of: "-", with: "")) {
                                            profitLoss = "-" + String(abs(amount))
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                                .font(.caption)
                            }
                        } else {
                            // Separate Income/Expenses Entry
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Income Amount", text: $income)
                                    .keyboardType(.numbersAndPunctuation)

                                TextField("Expenses Amount", text: $expenses)
                                    .keyboardType(.numbersAndPunctuation)

                                HStack {
                                    Text("P/L: ")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    let incomeVal = Double(income) ?? 0
                                    let expenseVal = Double(expenses) ?? 0
                                    let pl = incomeVal - expenseVal
                                    Text(String(format: "\(dataManager.currencySymbol)%.2f", pl))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(pl >= 0 ? .green : .red)
                                }
                                .padding(.top, 4)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Investment Amount (optional)", text: $investments)
                                .keyboardType(.numbersAndPunctuation)

                            Text("Track investments made during this month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        TextField("Note (optional)", text: $note)
                    }

                    if existingManualPL != nil {
                        Section {
                            Button("Delete Manual Entry", role: .destructive) {
                                if let existing = existingManualPL {
                                    dataManager.deleteManualPL(existing)
                                }
                                dismiss()
                            }
                        }
                    }
                }
            }
            .onAppear {
                if let existing = existingManualPL {
                    investments = String(existing.investments)
                    note = existing.note

                    // Determine entry mode based on existing data
                    if existing.profitLoss != nil {
                        entryMode = 0
                        profitLoss = String(existing.profitLoss ?? 0)
                    } else {
                        entryMode = 1
                        income = String(existing.income ?? 0)
                        expenses = String(existing.expenses ?? 0)
                    }
                }
            }
        }
    }

    private func saveManualPL() {
        let investmentAmount = Double(investments) ?? 0

        let manualPL: ManualPL

        if entryMode == 0 {
            // Direct P/L mode
            let plAmount = Double(profitLoss) ?? 0
            guard plAmount != 0 || investmentAmount != 0 else { return }

            manualPL = ManualPL(
                month: month,
                year: selectedYear,
                profitLoss: plAmount,
                investments: investmentAmount,
                note: note
            )
        } else {
            // Separate Income/Expenses mode
            let incomeAmount = Double(income) ?? 0
            let expenseAmount = Double(expenses) ?? 0
            guard incomeAmount != 0 || expenseAmount != 0 || investmentAmount != 0 else { return }

            manualPL = ManualPL(
                month: month,
                year: selectedYear,
                income: incomeAmount,
                expenses: expenseAmount,
                investments: investmentAmount,
                note: note
            )
        }

        dataManager.addManualPL(manualPL)
        dismiss()
    }
}

#Preview {
    StatsView()
        .environmentObject(DataManager())
}