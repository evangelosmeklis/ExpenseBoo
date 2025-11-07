import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categories: [Category] = []
    @Published var incomes: [Income] = []
    @Published var investments: [Investment] = []
    @Published var subscriptions: [Subscription] = []
    @Published var manualPLs: [ManualPL] = []
    @Published var settings: Settings = Settings()

    private let expensesKey = "expenses"
    private let categoriesKey = "categories"
    private let incomesKey = "incomes"
    private let investmentsKey = "investments"
    private let subscriptionsKey = "subscriptions"
    private let manualPLsKey = "manualPLs"
    private let settingsKey = "settings"
    
    init() {
        loadData()
        createDefaultCategories()
        fixExistingSubscriptionDates()
    }
    
    func loadData() {
        if let expensesData = UserDefaults.standard.data(forKey: expensesKey),
           let decodedExpenses = try? JSONDecoder().decode([Expense].self, from: expensesData) {
            expenses = decodedExpenses
        }
        
        if let categoriesData = UserDefaults.standard.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            categories = decodedCategories
        }
        
        if let incomesData = UserDefaults.standard.data(forKey: incomesKey),
           let decodedIncomes = try? JSONDecoder().decode([Income].self, from: incomesData) {
            incomes = decodedIncomes
        }

        if let investmentsData = UserDefaults.standard.data(forKey: investmentsKey),
           let decodedInvestments = try? JSONDecoder().decode([Investment].self, from: investmentsData) {
            investments = decodedInvestments
        }

        if let subscriptionsData = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decodedSubscriptions = try? JSONDecoder().decode([Subscription].self, from: subscriptionsData) {
            subscriptions = decodedSubscriptions
        }

        if let manualPLsData = UserDefaults.standard.data(forKey: manualPLsKey),
           let decodedManualPLs = try? JSONDecoder().decode([ManualPL].self, from: manualPLsData) {
            manualPLs = decodedManualPLs
        }

        if let settingsData = UserDefaults.standard.data(forKey: settingsKey),
           let decodedSettings = try? JSONDecoder().decode(Settings.self, from: settingsData) {
            settings = decodedSettings
        }
    }
    
    func saveData() {
        if let expensesData = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(expensesData, forKey: expensesKey)
        }
        
        if let categoriesData = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(categoriesData, forKey: categoriesKey)
        }
        
        if let incomesData = try? JSONEncoder().encode(incomes) {
            UserDefaults.standard.set(incomesData, forKey: incomesKey)
        }

        if let investmentsData = try? JSONEncoder().encode(investments) {
            UserDefaults.standard.set(investmentsData, forKey: investmentsKey)
        }

        if let subscriptionsData = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(subscriptionsData, forKey: subscriptionsKey)
        }

        if let manualPLsData = try? JSONEncoder().encode(manualPLs) {
            UserDefaults.standard.set(manualPLsData, forKey: manualPLsKey)
        }

        if let settingsData = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(settingsData, forKey: settingsKey)
        }
    }
    
    private func createDefaultCategories() {
        if categories.isEmpty {
            categories = [
                Category(name: "Food", color: .orange),
                Category(name: "Transportation", color: .blue),
                Category(name: "Shopping", color: .purple),
                Category(name: "Entertainment", color: .green),
                Category(name: "Bills", color: .red),
                Category(name: "Other", color: .gray)
            ]
            saveData()
        }
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveData()
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveData()
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveData()
    }
    
    func addIncome(_ income: Income) {
        incomes.append(income)
        saveData()
    }

    func addInvestment(_ investment: Investment) {
        investments.append(investment)
        saveData()
    }

    func updateInvestment(_ investment: Investment) {
        if let index = investments.firstIndex(where: { $0.id == investment.id }) {
            investments[index] = investment
            saveData()
        }
    }

    func deleteInvestment(_ investment: Investment) {
        investments.removeAll { $0.id == investment.id }
        saveData()
    }

    func updateSettings(_ newSettings: Settings) {
        settings = newSettings
        saveData()
    }
    
    func getCurrentMonthExpenses() -> [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        return expenses.filter { expense in
            expense.date >= startOfMonth && expense.date <= now
        }
    }
    
    func getCurrentMonthIncome() -> Double {
        let currentPeriodIncomes = getCurrentPeriodIncomes()
        return currentPeriodIncomes.reduce(0) { $0 + $1.amount }
    }

    func getCurrentMonthInvestments() -> [Investment] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        return investments.filter { investment in
            investment.date >= startOfMonth && investment.date <= now
        }
    }

    func getCurrentMonthInvestmentTotal() -> Double {
        return getCurrentMonthInvestments().reduce(0) { $0 + $1.amount }
    }

    private func getCurrentPeriodIncomes() -> [Income] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now

        return incomes.filter { income in
            income.date >= startOfMonth && income.date <= now
        }
    }
    
    
    func getCurrentBalance() -> Double {
        let totalIncome = getCurrentMonthIncome()
        let totalExpenses = getCurrentMonthExpenses().reduce(0) { $0 + $1.amount }
        return totalIncome - totalExpenses
    }
    
    func getCategoryById(_ id: UUID?) -> Category? {
        guard let id = id else { return nil }
        return categories.first { $0.id == id }
    }
    
    var currencySymbol: String {
        return settings.currency.symbol
    }
    
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveData()
    }
    
    func updateSubscription(_ subscription: Subscription) {
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index] = subscription
            saveData()
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
        saveData()
    }
    
    func addSubscriptionExpenses() {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let activeSubscriptions = subscriptions.filter { $0.isActive && $0.startDate <= Date() }

        for subscription in activeSubscriptions {
            let hasExpenseThisMonth = expenses.contains { expense in
                expense.comment.contains("Subscription: \(subscription.name)") &&
                expense.date >= startOfMonth
            }

            if !hasExpenseThisMonth {
                let subscriptionExpense = Expense(
                    amount: subscription.amount,
                    comment: "Subscription: \(subscription.name)",
                    date: startOfMonth,
                    categoryId: subscription.categoryId
                )
                expenses.append(subscriptionExpense)
            }
        }
        saveData()
    }

    func fixExistingSubscriptionDates() {
        let calendar = Calendar.current
        var hasChanges = false

        for i in 0..<expenses.count {
            let expense = expenses[i]
            // Check if this is a subscription expense
            if expense.comment.hasPrefix("Subscription:") {
                // Get the start of the month for this expense's date
                let startOfMonth = calendar.dateInterval(of: .month, for: expense.date)?.start ?? expense.date

                // If the expense is not on the 1st of the month, fix it
                if expense.date != startOfMonth {
                    expenses[i].date = startOfMonth
                    hasChanges = true
                }
            }
        }

        if hasChanges {
            saveData()
        }
    }
    
    func updateIncome(_ income: Income) {
        if let index = incomes.firstIndex(where: { $0.id == income.id }) {
            incomes[index] = income
            saveData()
        }
    }
    
    func deleteIncome(_ income: Income) {
        incomes.removeAll { $0.id == income.id }
        saveData()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveData()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }
    
    func getBudgetPeriodForDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .month, for: date)?.start ?? date
    }
    
    func getExpensesGroupedByBudgetPeriod() -> [(key: String, value: [Expense])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: expenses) { expense in
            let periodStart = getBudgetPeriodForDate(expense.date)
            return formatter.string(from: periodStart)
        }

        return grouped.sorted { first, second in
            let firstDate = formatter.date(from: first.key) ?? Date.distantPast
            let secondDate = formatter.date(from: second.key) ?? Date.distantPast
            return firstDate > secondDate
        }
    }

    func convertExpenseToInvestment(_ expense: Expense) {
        let investment = Investment(
            amount: expense.amount,
            comment: expense.comment,
            date: expense.date,
            categoryId: expense.categoryId
        )

        investments.append(investment)
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }

    // MARK: - Stats Functions
    func getAvailableYears() -> [Int] {
        let allDates = expenses.map { $0.date } + incomes.map { $0.date } + investments.map { $0.date }
        let years = Set(allDates.map { Calendar.current.component(.year, from: $0) })
        return Array(years).sorted(by: >)
    }

    func getMonthlyStats(for year: Int) -> [MonthlyStats] {
        var monthlyStats: [MonthlyStats] = []

        for month in 1...12 {
            let stats = getStatsForMonth(month: month, year: year)
            monthlyStats.append(stats)
        }

        return monthlyStats
    }

    private func getStatsForMonth(month: Int, year: Int) -> MonthlyStats {
        let calendar = Calendar.current

        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? Date()

        let monthExpenses = expenses.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        let monthIncomes = incomes.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
        let monthInvestments = investments.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }

        let totalExpenses = monthExpenses.reduce(0) { $0 + $1.amount }
        let totalIncome = monthIncomes.reduce(0) { $0 + $1.amount }
        let totalInvestments = monthInvestments.reduce(0) { $0 + $1.amount }

        // Check for manual P/L entry for this month
        if let manualPL = manualPLs.first(where: { $0.month == month && $0.year == year }) {
            return MonthlyStats(
                month: month,
                year: year,
                income: manualPL.effectiveIncome,
                expenses: manualPL.effectiveExpenses,
                investments: manualPL.investments,
                profitLoss: manualPL.effectiveProfitLoss
            )
        }

        let profitLoss = totalIncome - totalExpenses

        return MonthlyStats(
            month: month,
            year: year,
            income: totalIncome,
            expenses: totalExpenses,
            investments: totalInvestments,
            profitLoss: profitLoss
        )
    }

    // MARK: - Manual P/L Functions
    func addManualPL(_ manualPL: ManualPL) {
        // Remove existing manual entry for same month/year
        manualPLs.removeAll { $0.month == manualPL.month && $0.year == manualPL.year }
        manualPLs.append(manualPL)
        saveData()
    }

    func deleteManualPL(_ manualPL: ManualPL) {
        manualPLs.removeAll { $0.id == manualPL.id }
        saveData()
    }

    func getManualPL(for month: Int, year: Int) -> ManualPL? {
        return manualPLs.first { $0.month == month && $0.year == year }
    }

    // MARK: - Yearly Statistics
    func getYearlyStats(for year: Int) -> YearlyStats {
        let monthlyStats = getMonthlyStats(for: year)

        let totalIncome = monthlyStats.reduce(0) { $0 + $1.income }
        let totalExpenses = monthlyStats.reduce(0) { $0 + $1.expenses }
        let totalInvestments = monthlyStats.reduce(0) { $0 + $1.investments }
        let totalProfitLoss = monthlyStats.reduce(0) { $0 + $1.profitLoss }
        let totalProfitLossWithoutInvestments = totalProfitLoss - totalInvestments

        let statsWithData = monthlyStats.filter { $0.income > 0 || $0.expenses > 0 || $0.profitLoss != 0 }
        let averageMonthlyPL = statsWithData.isEmpty ? 0 : totalProfitLoss / Double(statsWithData.count)
        let averageMonthlyPLWithoutInvestments = statsWithData.isEmpty ? 0 : totalProfitLossWithoutInvestments / Double(statsWithData.count)

        let bestMonth = monthlyStats.max(by: { $0.profitLoss < $1.profitLoss })
        let worstMonth = monthlyStats.min(by: { $0.profitLoss < $1.profitLoss })

        return YearlyStats(
            year: year,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            totalInvestments: totalInvestments,
            totalProfitLoss: totalProfitLoss,
            totalProfitLossWithoutInvestments: totalProfitLossWithoutInvestments,
            averageMonthlyPL: averageMonthlyPL,
            averageMonthlyPLWithoutInvestments: averageMonthlyPLWithoutInvestments,
            bestMonth: bestMonth?.monthName ?? "N/A",
            worstMonth: worstMonth?.monthName ?? "N/A",
            bestMonthPL: bestMonth?.profitLoss ?? 0,
            worstMonthPL: worstMonth?.profitLoss ?? 0
        )
    }
}