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
                    
                    if selectedPeriod == 1 {
                        HStack {
                            Button(action: { showingDatePicker = true }) {
                                Text("From: \(startDate, formatter: dateFormatter) - To: \(endDate, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                    }
                    
                    // P/L Summary
                    VStack(spacing: 8) {
                        HStack {
                            Text("Income:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(dataManager.currencySymbol)\(incomeTotal, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }

                        HStack {
                            Text("Expenses:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(dataManager.currencySymbol)\(expenseTotal, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }

                        HStack {
                            Text("Investments:")
                                .font(.subheadline)
                            Spacer()
                            Text("\(dataManager.currencySymbol)\(investmentTotal, specifier: "%.2f")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }

                        Divider()

                        HStack {
                            Text("P/L:")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(dataManager.currencySymbol)\(profitLoss, specifier: "%.2f")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(profitLoss >= 0 ? .green : .red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                if filteredExpenses.isEmpty && filteredIncomes.isEmpty && filteredInvestments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("No transactions yet")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Start adding income, expenses, and investments")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // Income Section
                        if !filteredIncomes.isEmpty {
                            Section(header: HStack {
                                Text("Income")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                Spacer()
                                Text("\(dataManager.currencySymbol)\(incomeTotal, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }) {
                                ForEach(filteredIncomes) { income in
                                    IncomeRowView(income: income)
                                }
                            }
                        }

                        // Expenses Section
                        if !filteredExpenses.isEmpty {
                            Section(header: HStack {
                                Text("Expenses")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Spacer()
                                Text("\(dataManager.currencySymbol)\(expenseTotal, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }) {
                                ForEach(filteredExpenses) { expense in
                                    ExpenseRowView(expense: expense)
                                }
                            }
                        }

                        // Investments Section
                        if !filteredInvestments.isEmpty {
                            Section(header: HStack {
                                Text("Investments")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                Spacer()
                                Text("\(dataManager.currencySymbol)\(investmentTotal, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                            }) {
                                ForEach(filteredInvestments) { investment in
                                    InvestmentRowView(investment: investment)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("P/L")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
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

    var category: Category? {
        dataManager.getCategoryById(expense.categoryId)
    }

    var body: some View {
        HStack {
            if let category = category {
                Circle()
                    .fill(category.color)
                    .frame(width: 12, height: 12)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.comment)
                    .font(.body)

                HStack {
                    Text(category?.name ?? "Uncategorized")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(expense.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(dataManager.currencySymbol)\(expense.amount, specifier: "%.2f")")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.red)
        }
        .padding(.vertical, 4)
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