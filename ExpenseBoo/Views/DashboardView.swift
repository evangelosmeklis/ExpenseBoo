import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var showingSettings = false
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Welcome Back"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                AppTheme.Colors.primaryBackground
                    .ignoresSafeArea()
                
                // Subtle Ambient Gradient Orbs (Optional flair)
                GeometryReader { proxy in
                    Circle()
                        .fill(AppTheme.Colors.electricCyan.opacity(0.1))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -100)
                    
                    Circle()
                        .fill(AppTheme.Colors.vibrantPurple.opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .position(x: proxy.size.width, y: proxy.size.height * 0.4)
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(AppTheme.Fonts.caption(16))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                                Text("Evangelos") // Placeholder for user name
                                    .font(AppTheme.Fonts.title(32))
                                    .foregroundColor(AppTheme.Colors.primaryText)
                            }
                            Spacer()
                            // Profile Image or Icon
                            Button(action: { showingSettings = true }) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
                            }
                        }
                        .padding(.horizontal)
                        
                        BalanceCard()
                            .padding(.horizontal)

                        QuickActionsSection()
                            .padding(.horizontal)

                        RecentExpensesSection()
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .environmentObject(dataManager)
    }
}

struct BalanceCard: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Total Balance")
                    .font(AppTheme.Fonts.body())
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Image(systemName: "simcard") // Chip icon for stylized card look
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(dataManager.currencySymbol)
                    .font(AppTheme.Fonts.title(24))
                    .foregroundColor(.white.opacity(0.9))
                Text("\(dataManager.getCurrentBalance(), specifier: "%.2f")")
                    .font(AppTheme.Fonts.title(40))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            
            HStack(spacing: 0) {
                // Income
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.down.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income")
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthIncome(), specifier: "%.0f")")
                            .font(AppTheme.Fonts.headline(16))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Expense
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Expense")
                            .font(AppTheme.Fonts.caption(12))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(dataManager.currencySymbol)\(dataManager.getCurrentMonthExpenses().reduce(0) { $0 + $1.amount }, specifier: "%.0f")")
                            .font(AppTheme.Fonts.headline(16))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.2, blue: 0.3),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
    }
}

struct QuickActionsSection: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @State private var showingAddInvestment = false

    var body: some View {
        HStack(spacing: 20) {
            QuickActionButton(
                icon: "minus",
                label: "Expense",
                color: AppTheme.Colors.expense,
                action: { showingAddExpense = true }
            )
            
            QuickActionButton(
                icon: "plus",
                label: "Income",
                color: AppTheme.Colors.income,
                action: { showingAddIncome = true }
            )
            
            QuickActionButton(
                icon: "chart.line.uptrend.xyaxis",
                label: "Invest",
                color: AppTheme.Colors.investment,
                action: { showingAddInvestment = true }
            )
        }
        .sheet(isPresented: $showingAddExpense) { AddExpenseView() }
        .sheet(isPresented: $showingAddIncome) { AddIncomeView() }
        .sheet(isPresented: $showingAddInvestment) { AddInvestmentView() }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(color)
                    )
                
                Text(label)
                    .font(AppTheme.Fonts.caption(13))
                    .foregroundColor(AppTheme.Colors.primaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentExpensesSection: View {
    @EnvironmentObject var dataManager: DataManager
    
    var recentExpenses: [Expense] {
        Array(dataManager.getCurrentMonthExpenses().sorted { $0.date > $1.date }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            if recentExpenses.isEmpty {
                emptyStateView
            } else {
                expensesListView
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Recent Transactions")
                .font(AppTheme.Fonts.headline(18))
                .foregroundColor(AppTheme.Colors.primaryText)
            
            Spacer()
            
            NavigationLink(destination: ExpensesView()) {
                Text("View All")
                    .font(AppTheme.Fonts.caption(14))
                    .foregroundColor(AppTheme.Colors.electricCyan)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.5))
            Text("No expenses yet this month")
                .font(AppTheme.Fonts.body())
                .foregroundColor(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(AppTheme.Colors.secondaryBackground)
        .cornerRadius(16)
    }
    
    private var expensesListView: some View {
        VStack(spacing: 0) {
            ForEach(Array(recentExpenses.enumerated()), id: \.offset) { index, expense in
                expenseRow(expense)
                
                if index < recentExpenses.count - 1 {
                    Divider()
                        .opacity(0.5)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func expenseRow(_ expense: Expense) -> some View {
        let categoryName = dataManager.getCategoryById(expense.categoryId)?.name ?? "Uncategorized"
        
        return HStack {
            // Category Icon
            Circle()
                .fill(AppTheme.Colors.secondaryBackground)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(categoryName.prefix(1))) // Simple placeholder icon
                        .font(AppTheme.Fonts.headline(18))
                        .foregroundColor(AppTheme.Colors.primaryText)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.comment.isEmpty ? categoryName : expense.comment)
                    .font(AppTheme.Fonts.body(16))
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                Text(expense.date, style: .date)
                    .font(AppTheme.Fonts.caption(12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            Text("-\(dataManager.currencySymbol)\(expense.amount, specifier: "%.2f")")
                .font(AppTheme.Fonts.number(16))
                .foregroundColor(AppTheme.Colors.expense)
        }
        .padding(.vertical, 12)
    }
}


#Preview {
    DashboardView()
        .environmentObject(DataManager())
}