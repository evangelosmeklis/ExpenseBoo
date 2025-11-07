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
            .background(AppTheme.Colors.primaryBackground.ignoresSafeArea())
            .navigationTitle("ExpenseBoo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ExpenseBoo")
                        .font(AppTheme.Fonts.headline(20))
                        .foregroundColor(AppTheme.Colors.electricCyan)
                }
            }
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
        VStack(spacing: 16) {
            Text(">> CURRENT_BALANCE")
                .font(AppTheme.Fonts.caption(11))
                .foregroundColor(AppTheme.Colors.electricCyan)
                .tracking(2)
            
            Text("\(dataManager.currencySymbol)\(dataManager.getCurrentBalance(), specifier: "%.2f")")
                .font(AppTheme.Fonts.title(36))
                .foregroundColor(dataManager.getCurrentBalance() >= 0 ? AppTheme.Colors.neonGreen : AppTheme.Colors.techOrange)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(AppTheme.Colors.income)
                        Text("INCOME")
                            .font(AppTheme.Fonts.caption(10))
                            .foregroundColor(AppTheme.Colors.income)
                            .tracking(1)
                    }
                    Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthIncome(), specifier: "%.2f")")
                        .font(AppTheme.Fonts.number(16))
                        .foregroundColor(AppTheme.Colors.income)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("EXPENSE")
                            .font(AppTheme.Fonts.caption(10))
                            .foregroundColor(AppTheme.Colors.expense)
                            .tracking(1)
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(AppTheme.Colors.expense)
                    }
                    Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthExpenses().reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        .font(AppTheme.Fonts.number(16))
                        .foregroundColor(AppTheme.Colors.expense)
                }
            }
        }
        .padding(20)
        .techCard(glowColor: AppTheme.Colors.electricCyan)
    }
}

struct QuickActionsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showingAddInvestment = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(">> QUICK_ACTIONS")
                .font(AppTheme.Fonts.caption(11))
                .foregroundColor(AppTheme.Colors.electricCyan)
                .tracking(2)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button(action: { showingAddExpense = true }) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("EXPENSE")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.expense.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.Colors.expense, lineWidth: 1.5)
                        )
                        .foregroundColor(AppTheme.Colors.expense)
                    }

                    Button(action: { showingAddIncome = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("INCOME")
                                .font(AppTheme.Fonts.body(13))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.Colors.income.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.Colors.income, lineWidth: 1.5)
                        )
                        .foregroundColor(AppTheme.Colors.income)
                    }
                }

                Button(action: { showingAddInvestment = true }) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("INVESTMENT")
                            .font(AppTheme.Fonts.body(13))
                            .tracking(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.investment.opacity(0.15))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.Colors.investment, lineWidth: 1.5)
                    )
                    .foregroundColor(AppTheme.Colors.investment)
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
                Text(">> RECENT_EXPENSES")
                    .font(AppTheme.Fonts.caption(11))
                    .foregroundColor(AppTheme.Colors.electricCyan)
                    .tracking(2)
                Spacer()
                NavigationLink(destination: ExpensesView()) {
                    Text("[VIEW_ALL]")
                        .font(AppTheme.Fonts.caption(10))
                        .foregroundColor(AppTheme.Colors.vibrantPurple)
                        .tracking(1)
                }
            }
            
            if recentExpenses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.5))
                    Text("// NO_EXPENSES_THIS_MONTH")
                        .font(AppTheme.Fonts.caption())
                        .foregroundColor(AppTheme.Colors.electricCyan.opacity(0.7))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .techCard(glowColor: AppTheme.Colors.electricCyan.opacity(0.3))
            } else {
                VStack(spacing: 10) {
                    ForEach(recentExpenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
                .padding(12)
                .techCard(glowColor: AppTheme.Colors.expense.opacity(0.4))
            }
        }
    }
}


#Preview {
    DashboardView()
        .environmentObject(DataManager())
}