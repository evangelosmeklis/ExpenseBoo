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
                    
                    SavingGoalsSection()
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
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
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView()
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

struct SavingGoalsSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    var activeGoals: [SavingGoal] {
        Array(dataManager.savingGoals.filter { $0.targetDate >= Date() && !$0.isGeneric }.prefix(3))
    }
    
    var genericGoal: SavingGoal? {
        dataManager.savingGoals.first { $0.isGeneric }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saving Goals")
                    .font(.headline)
                Spacer()
                NavigationLink("See All", destination: SavingGoalsView())
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                // Show generic goal first if it exists
                if let genericGoal = genericGoal {
                    GenericGoalRowView(goal: genericGoal)
                }
                
                // Show specific goals
                if !activeGoals.isEmpty {
                    ForEach(activeGoals) { goal in
                        SavingGoalRowView(goal: goal)
                    }
                } else if genericGoal == nil {
                    Text("No active saving goals")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
}