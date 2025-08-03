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
    
    private func getExpensesInDateRange() -> [Expense] {
        return dataManager.expenses.filter { expense in
            expense.date >= startDate && expense.date <= endDate
        }
    }
    
    var expenseTotal: Double {
        return filteredExpenses.reduce(0) { $0 + $1.amount }
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
                    
                    // Expense Total
                    HStack {
                        Text("Total:")
                            .font(.headline)
                        Spacer()
                        Text("\(dataManager.currencySymbol)\(expenseTotal, specifier: "%.2f")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                if filteredExpenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No expenses yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the + button to add your first expense")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if selectedPeriod == 0 {
                            // Current month - group by day
                            ForEach(groupedExpenses, id: \.key) { group in
                                Section(header: Text(group.key)) {
                                    ForEach(group.value) { expense in
                                        ExpenseRowView(expense: expense)
                                    }
                                }
                            }
                        } else {
                            // Date range - group by day
                            ForEach(groupedExpensesForDateRange, id: \.key) { group in
                                Section(header: Text(group.key)) {
                                    ForEach(group.value) { expense in
                                        ExpenseRowView(expense: expense)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
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
        .sheet(isPresented: $showingEditExpense) {
            EditExpenseView(expense: expense)
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