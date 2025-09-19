import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    BalanceCard()

                    QuickActionsSection()

                    RecentExpensesSection()
                }
                .padding()
            }
            .navigationTitle("ExpenseBoo")
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
        }
        .environmentObject(dataManager)
    }
}

struct BalanceCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var currentBalance: Double {
        dataManager.getCurrentBalance()
    }
    
    var currentIncome: Double {
        dataManager.getCurrentMonthIncome()
    }
    
    var currentExpenses: Double {
        dataManager.getCurrentMonthExpenses().reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Current Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(dataManager.currencySymbol)\(dataManager.getCurrentBalance(), specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(dataManager.getCurrentBalance() >= 0 ? .green : .red)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Income")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthIncome(), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Expenses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthExpenses().reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showingAddInvestment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: { showingAddExpense = true }) {
                        Label("Add Expense", systemImage: "minus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }

                    Button(action: { showingAddIncome = true }) {
                        Label("Add Income", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(10)
                    }
                }

                Button(action: { showingAddInvestment = true }) {
                    Label("Add Investment", systemImage: "chart.line.uptrend.xyaxis")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView()
        }
        .sheet(isPresented: $showingAddInvestment) {
            AddInvestmentView()
        }
    }
}

struct RecentExpensesSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    var recentExpenses: [Expense] {
        Array(dataManager.getCurrentMonthExpenses().sorted { $0.date > $1.date }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Expenses")
                    .font(.headline)
                Spacer()
                NavigationLink("See All", destination: ExpensesView())
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            if recentExpenses.isEmpty {
                Text("No expenses this month")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(recentExpenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
        }
    }
}


#Preview {
    DashboardView()
        .environmentObject(DataManager())
}