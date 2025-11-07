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
                .accentColor(AppTheme.Colors.electricCyan)

                // Year Picker
                HStack {
                    Text(">> YEAR:")
                        .font(AppTheme.Fonts.body(14))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(2)

                    Spacer()

                    Picker("Year", selection: $selectedYear) {
                        ForEach(availableYears, id: \.self) { year in
                            Text(String(year))
                                .font(AppTheme.Fonts.body())
                                .tag(year)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(AppTheme.Colors.electricCyan)
                }
                .padding(.horizontal)

                if selectedView == 0 {
                    // Monthly View
                    VStack(spacing: 16) {
                        Toggle(isOn: $showFullYear) {
                            Text(showFullYear ? "SHOWING_FULL_YEAR" : "SHOWING_UP_TO_CURRENT")
                                .font(AppTheme.Fonts.caption(11))
                                .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.8))
                                .tracking(1)
                        }
                        .tint(AppTheme.Colors.electricCyan)
                        .padding(.horizontal)
                    }

                    // Stats List
                    List {
                        ForEach(filteredStats) { monthStats in
                            MonthlyStatsRowView(stats: monthStats, year: selectedYear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.Colors.primaryBackground)
                } else {
                    // Yearly Summary View
                    YearlyStatsView(year: selectedYear)
                }
            }
            .background(AppTheme.Colors.primaryBackground.ignoresSafeArea())
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(">> STATS")
                        .font(AppTheme.Fonts.headline(18))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(2)
                }
                if selectedView == 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddManualPL = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.Colors.electricCyan)
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(stats.monthName.uppercased())
                    .font(AppTheme.Fonts.headline(16))
                    .tracking(1)

                if isManualEntry {
                    Text("[MANUAL]")
                        .font(AppTheme.Fonts.caption(9))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.Colors.electricCyan.opacity(0.15))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(AppTheme.Colors.electricCyan, lineWidth: 1)
                        )
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("P/L")
                            .font(AppTheme.Fonts.caption(10))
                            .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                            .tracking(1)
                        if hasNoData || isManualEntry {
                            Image(systemName: "pencil.circle")
                                .font(AppTheme.Fonts.caption(10))
                                .foregroundColor(AppTheme.Colors.electricCyan)
                        }
                    }
                    Text("\(dataManager.currencySymbol)\(stats.profitLoss, specifier: "%.2f")")
                        .font(AppTheme.Fonts.number(16))
                        .foregroundColor(stats.profitLoss >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                }
            }

            if !isManualEntry {
                Divider()
                    .background(AppTheme.Colors.electricCyan.opacity(0.3))

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Label {
                            Text("\(dataManager.currencySymbol)\(stats.income, specifier: "%.2f")")
                                .font(AppTheme.Fonts.number(13))
                                .foregroundColor(AppTheme.Colors.income)
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.Colors.income)
                                .font(.system(size: 12))
                        }

                        Label {
                            Text("\(dataManager.currencySymbol)\(stats.expenses, specifier: "%.2f")")
                                .font(AppTheme.Fonts.number(13))
                                .foregroundColor(AppTheme.Colors.expense)
                        } icon: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(AppTheme.Colors.expense)
                                .font(.system(size: 12))
                        }

                        if stats.investments > 0 {
                            Label {
                                Text("\(dataManager.currencySymbol)\(stats.investments, specifier: "%.2f")")
                                    .font(AppTheme.Fonts.number(13))
                                    .foregroundColor(AppTheme.Colors.investment)
                            } icon: {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(AppTheme.Colors.investment)
                                    .font(.system(size: 12))
                            }
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
        .padding(12)
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
        .listRowBackground(AppTheme.Colors.cardBackground)
        .listRowSeparatorTint(AppTheme.Colors.electricCyan.opacity(0.2))
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
                VStack(spacing: 16) {
                    Text(">> YEARLY_SUMMARY")
                        .font(AppTheme.Fonts.caption(11))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Total Income",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalIncome),
                        color: AppTheme.Colors.income,
                        icon: "plus.circle.fill"
                    )

                    StatCard(
                        title: "Total Expenses",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalExpenses),
                        color: AppTheme.Colors.expense,
                        icon: "minus.circle.fill"
                    )

                    StatCard(
                        title: "Total Investments",
                        value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalInvestments),
                        color: AppTheme.Colors.investment,
                        icon: "chart.line.uptrend.xyaxis"
                    )

                        StatCard(
                            title: "Net P/L",
                            value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalProfitLoss),
                            color: yearlyStats.totalProfitLoss >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss,
                            icon: yearlyStats.totalProfitLoss >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                        )
                    }

                    // Centered card for P/L without investments
                    HStack {
                        Spacer()
                        StatCard(
                            title: "P/L without investments",
                            value: String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.totalProfitLossWithoutInvestments),
                            color: yearlyStats.totalProfitLossWithoutInvestments >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss,
                            icon: yearlyStats.totalProfitLossWithoutInvestments >= 0 ? "dollarsign.circle.fill" : "dollarsign.circle"
                        )
                        .frame(maxWidth: .infinity)
                        Spacer()
                    }
                }
                .padding(.horizontal)

                // Performance Metrics
                VStack(alignment: .leading, spacing: 12) {
                    Text(">> PERFORMANCE_METRICS")
                        .font(AppTheme.Fonts.caption(11))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                        .tracking(2)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Avg Monthly P/L:")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(0.5)
                            Spacer()
                            Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.averageMonthlyPL))
                                .font(AppTheme.Fonts.number(14))
                                .foregroundColor(yearlyStats.averageMonthlyPL >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        }

                        HStack {
                            Text("Avg P/L w/o invest:")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(0.5)
                            Spacer()
                            Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.averageMonthlyPLWithoutInvestments))
                                .font(AppTheme.Fonts.number(14))
                                .foregroundColor(yearlyStats.averageMonthlyPLWithoutInvestments >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        }

                        Divider()
                            .background(AppTheme.Colors.electricCyan.opacity(0.3))

                        HStack {
                            Text("Best Month:")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(0.5)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(yearlyStats.bestMonth.uppercased())
                                    .font(AppTheme.Fonts.body(12))
                                    .tracking(1)
                                Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.bestMonthPL))
                                    .font(AppTheme.Fonts.number(12))
                                    .foregroundColor(AppTheme.Colors.profit)
                            }
                        }

                        Divider()
                            .background(AppTheme.Colors.electricCyan.opacity(0.3))

                        HStack {
                            Text("Worst Month:")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(0.5)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(yearlyStats.worstMonth.uppercased())
                                    .font(AppTheme.Fonts.body(12))
                                    .tracking(1)
                                Text(String(format: "\(dataManager.currencySymbol)%.2f", yearlyStats.worstMonthPL))
                                    .font(AppTheme.Fonts.number(12))
                                    .foregroundColor(AppTheme.Colors.loss)
                            }
                        }
                    }
                    .padding(16)
                    .techCard(glowColor: AppTheme.Colors.vibrantPurple.opacity(0.5))
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
        }
        .background(AppTheme.Colors.primaryBackground.ignoresSafeArea())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
                Spacer()
            }

            Text(title.uppercased())
                .font(AppTheme.Fonts.caption(9))
                .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                .tracking(1)

            Text(value)
                .font(AppTheme.Fonts.number(16))
                .foregroundColor(color)
        }
        .padding(16)
        .techCard(glowColor: color.opacity(0.5))
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