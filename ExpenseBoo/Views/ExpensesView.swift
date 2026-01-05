import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var selectedPeriod = 0
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingDatePicker = false
    
    var filteredExpenses: [Expense] {
        switch selectedPeriod {
        case 0:
            return dataManager.getCurrentMonthExpenses().sorted { $0.date > $1.date }
        case 1:
            return getExpensesInDateRange().sorted { $0.date > $1.date }
        default:
            return []
        }
    }

    var filteredIncomes: [Income] {
        switch selectedPeriod {
        case 0:
            return getCurrentMonthIncomes().sorted { $0.date > $1.date }
        case 1:
            return getIncomesInDateRange().sorted { $0.date > $1.date }
        default:
            return []
        }
    }

    var filteredInvestments: [Investment] {
        switch selectedPeriod {
        case 0:
            return dataManager.getCurrentMonthInvestments().sorted { $0.date > $1.date }
        case 1:
            return getInvestmentsInDateRange().sorted { $0.date > $1.date }
        default:
            return []
        }
    }

    private func getCurrentMonthIncomes() -> [Income] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        return dataManager.incomes.filter { income in
            income.date >= startOfMonth && income.date <= now
        }
    }

    private func getExpensesInDateRange() -> [Expense] {
        return dataManager.expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }

    private func getIncomesInDateRange() -> [Income] {
        return dataManager.incomes.filter { income in
            income.date >= startDate && income.date <= endDate
        }
    }

    private func getInvestmentsInDateRange() -> [Investment] {
        return dataManager.investments.filter { investment in
            investment.date >= startDate && investment.date <= endDate
        }
    }

    var expenseTotal: Double {
        return filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var incomeTotal: Double {
        return filteredIncomes.reduce(0) { $0 + $1.amount }
    }

    var investmentTotal: Double {
        return filteredInvestments.reduce(0) { $0 + $1.amount }
    }

    var profitLoss: Double {
        return incomeTotal - expenseTotal
    }

    var profitLossWithoutInvestments: Double {
        return incomeTotal - expenseTotal - investmentTotal
    }
    
    var groupedExpensesByBudgetPeriod: [(key: String, value: [Expense])] {
        return dataManager.getExpensesGroupedByBudgetPeriod()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var groupedExpensesForDateRange: [(key: String, value: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let grouped = Dictionary(grouping: getExpensesInDateRange()) { expense in
            formatter.string(from: expense.date)
        }
        
        return grouped.sorted { first, second in
            let firstDate = formatter.date(from: first.key) ?? Date.distantPast
            let secondDate = formatter.date(from: second.key) ?? Date.distantPast
            return firstDate > secondDate
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 12) {
                    Picker("Period", selection: $selectedPeriod) {
                        Text("This Month").tag(0)
                        Text("Date Range").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .accentColor(AppTheme.Colors.electricCyan)
                    
                    if selectedPeriod == 1 {
                        HStack {
                            Button(action: { showingDatePicker = true }) {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text("\(startDate, formatter: dateFormatter) - \(endDate, formatter: dateFormatter)")
                                }
                                .font(AppTheme.Fonts.caption(12))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppTheme.Colors.secondaryBackground)
                                .cornerRadius(20)
                                .foregroundColor(AppTheme.Colors.primaryText)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // P/L Summary
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Text(dataManager.currencySymbol)
                                .font(AppTheme.Fonts.title(24))
                                .foregroundColor(profitLoss >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                            Text("\(abs(profitLoss), specifier: "%.2f")")
                                .font(AppTheme.Fonts.title(40))
                                .foregroundColor(profitLoss >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        }
                        .padding(.vertical, 4)

                        HStack(spacing: 32) {
                            VStack(spacing: 4) {
                                Text("Income")
                                    .font(AppTheme.Fonts.caption(12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text("\(dataManager.currencySymbol)\(incomeTotal, specifier: "%.2f")")
                                    .font(AppTheme.Fonts.headline(16))
                                    .foregroundColor(AppTheme.Colors.income)
                            }

                            VStack(spacing: 4) {
                                Text("Expenses")
                                    .font(AppTheme.Fonts.caption(12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text("\(dataManager.currencySymbol)\(expenseTotal, specifier: "%.2f")")
                                    .font(AppTheme.Fonts.headline(16))
                                    .foregroundColor(AppTheme.Colors.expense)
                            }

                            VStack(spacing: 4) {
                                Text("Investments")
                                    .font(AppTheme.Fonts.caption(12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text("\(dataManager.currencySymbol)\(investmentTotal, specifier: "%.2f")")
                                    .font(AppTheme.Fonts.headline(16))
                                    .foregroundColor(AppTheme.Colors.investment)
                            }
                        }
                        
                        Divider()
                            .overlay(AppTheme.Colors.secondaryText.opacity(0.1))

                        HStack {
                            Text("Net Balance (w/o invest)")
                                .font(AppTheme.Fonts.caption(12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                            Spacer()
                            Text("\(dataManager.currencySymbol)\(profitLossWithoutInvestments, specifier: "%.2f")")
                                .font(AppTheme.Fonts.body(14))
                                .foregroundColor(profitLossWithoutInvestments >= 0 ? AppTheme.Colors.profit : AppTheme.Colors.loss)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
                
                if filteredExpenses.isEmpty && filteredIncomes.isEmpty && filteredInvestments.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.3))

                        Text("No Transactions Yet")
                            .font(AppTheme.Fonts.headline(18))
                            .foregroundColor(AppTheme.Colors.primaryText)

                        Text("Start tracking your finances by adding new entries.")
                            .font(AppTheme.Fonts.body())
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Income Section
                        if !filteredIncomes.isEmpty {
                            Section(header: Text("Income")
                                .font(AppTheme.Fonts.headline(14))
                                .foregroundColor(AppTheme.Colors.secondaryText)) {
                                ForEach(filteredIncomes) { income in
                                    IncomeRowView(income: income)
                                }
                            }
                        }

                        // Expenses Section
                        if !filteredExpenses.isEmpty {
                            Section(header: Text("Expenses")
                                .font(AppTheme.Fonts.headline(14))
                                .foregroundColor(AppTheme.Colors.secondaryText)) {
                                ForEach(filteredExpenses) { expense in
                                    ExpenseRowView(expense: expense)
                                }
                            }
                        }

                        // Investments Section
                        if !filteredInvestments.isEmpty {
                            Section(header: Text("Investments")
                                .font(AppTheme.Fonts.headline(14))
                                .foregroundColor(AppTheme.Colors.secondaryText)) {
                                ForEach(filteredInvestments) { investment in
                                    InvestmentRowView(investment: investment)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.Colors.primaryBackground.ignoresSafeArea())
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, AppTheme.Colors.electricCyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingDatePicker) {
                DateRangePickerView(startDate: $startDate, endDate: $endDate)
            }
        }
    }
    
    private func getAllExpenses() -> [Expense] {
        return dataManager.expenses
    }
    
    private var groupedExpenses: [(key: String, value: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            formatter.string(from: expense.date)
        }
        
        return grouped.sorted { first, second in
            let firstDate = formatter.date(from: first.key) ?? Date.distantPast
            let secondDate = formatter.date(from: second.key) ?? Date.distantPast
            return firstDate > secondDate
        }
    }
}

struct ExpenseRowView: View {
    @EnvironmentObject var dataManager: DataManager
    let expense: Expense
    @State private var showingEditExpense = false
    @State private var showingConversionAlert = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon Placeholder
            Circle()
                .fill(AppTheme.Colors.expense.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.expense)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.comment.isEmpty ? (dataManager.getCategoryById(expense.categoryId)?.name ?? "Expense") : expense.comment)
                    .font(AppTheme.Fonts.body(16))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Text(dateFormatter.string(from: expense.date))
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            Spacer()

            Text("-\(dataManager.currencySymbol)\(expense.amount, specifier: "%.2f")")
                .font(AppTheme.Fonts.number(16))
                .foregroundColor(AppTheme.Colors.primaryText)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditExpense = true
        }
        .contextMenu {
            Button(action: { showingEditExpense = true }) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: { showingConversionAlert = true }) {
                Label("Convert to Investment", systemImage: "arrow.right.circle")
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            EditExpenseView(expense: expense)
        }
        .alert("Convert to Investment", isPresented: $showingConversionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Convert") {
                dataManager.convertExpenseToInvestment(expense)
            }
        } message: {
            Text("This will convert this expense to an investment. This action cannot be undone.")
        }
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(AppTheme.Colors.secondaryText.opacity(0.2))
    }
}

struct DateRangePickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Date Range")) {
                    DatePicker("From", selection: $startDate, displayedComponents: .date)
                    DatePicker("To", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    ExpensesView()
        .environmentObject(DataManager())
}