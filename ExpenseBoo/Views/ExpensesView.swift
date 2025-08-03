import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var selectedPeriod = 0
    
    var filteredExpenses: [Expense] {
        switch selectedPeriod {
        case 0:
            return dataManager.getCurrentMonthExpenses().sorted { $0.date > $1.date }
        case 1:
            return getAllExpenses().sorted { $0.date > $1.date }
        default:
            return []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Period", selection: $selectedPeriod) {
                    Text("This Month").tag(0)
                    Text("All Time").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
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
                        ForEach(groupedExpenses, id: \.key) { group in
                            Section(header: Text(group.key)) {
                                ForEach(group.value) { expense in
                                    ExpenseRowView(expense: expense)
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
    }
}

#Preview {
    ExpensesView()
        .environmentObject(DataManager())
}