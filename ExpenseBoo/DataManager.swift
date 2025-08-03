import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categories: [Category] = []
    @Published var incomes: [Income] = []
    @Published var savingGoals: [SavingGoal] = []
    @Published var subscriptions: [Subscription] = []
    @Published var settings: Settings = Settings()
    
    private let expensesKey = "expenses"
    private let categoriesKey = "categories"
    private let incomesKey = "incomes"
    private let savingGoalsKey = "savingGoals"
    private let subscriptionsKey = "subscriptions"
    private let settingsKey = "settings"
    
    init() {
        loadData()
        createDefaultCategories()
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
        
        if let savingGoalsData = UserDefaults.standard.data(forKey: savingGoalsKey),
           let decodedSavingGoals = try? JSONDecoder().decode([SavingGoal].self, from: savingGoalsData) {
            savingGoals = decodedSavingGoals
        }
        
        if let subscriptionsData = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decodedSubscriptions = try? JSONDecoder().decode([Subscription].self, from: subscriptionsData) {
            subscriptions = decodedSubscriptions
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
        
        if let savingGoalsData = try? JSONEncoder().encode(savingGoals) {
            UserDefaults.standard.set(savingGoalsData, forKey: savingGoalsKey)
        }
        
        if let subscriptionsData = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(subscriptionsData, forKey: subscriptionsKey)
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
    
    func addSavingGoal(_ goal: SavingGoal) {
        savingGoals.append(goal)
        saveData()
    }
    
    func updateSavingGoal(_ goal: SavingGoal) {
        if let index = savingGoals.firstIndex(where: { $0.id == goal.id }) {
            savingGoals[index] = goal
            saveData()
        }
    }
    
    func deleteSavingGoal(_ goal: SavingGoal) {
        savingGoals.removeAll { $0.id == goal.id }
        saveData()
    }
    
    func updateSettings(_ newSettings: Settings) {
        settings = newSettings
        saveData()
    }
    
    func getCurrentMonthExpenses() -> [Expense] {
        let now = Date()
        let startOfPeriod = getStartOfCurrentPeriod()
        
        return expenses.filter { expense in
            expense.date >= startOfPeriod && expense.date <= now
        }
    }
    
    func getCurrentMonthIncome() -> Double {
        let currentPeriodIncomes = getCurrentPeriodIncomes()
        return currentPeriodIncomes.reduce(0) { $0 + $1.amount }
    }
    
    private func getCurrentPeriodIncomes() -> [Income] {
        let startOfPeriod = getStartOfCurrentPeriod()
        let now = Date()
        
        return incomes.filter { income in
            income.date >= startOfPeriod && income.date <= now
        }
    }
    
    private func getStartOfCurrentPeriod() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch settings.resetType {
        case .payDay:
            let currentDay = calendar.component(.day, from: now)
            if currentDay >= settings.payDay {
                return calendar.date(from: DateComponents(year: calendar.component(.year, from: now),
                                                         month: calendar.component(.month, from: now),
                                                         day: settings.payDay)) ?? now
            } else {
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return calendar.date(from: DateComponents(year: calendar.component(.year, from: previousMonth),
                                                         month: calendar.component(.month, from: previousMonth),
                                                         day: settings.payDay)) ?? now
            }
            
        case .monthlyDate:
            let currentDay = calendar.component(.day, from: now)
            if currentDay >= settings.monthlyResetDate {
                return calendar.date(from: DateComponents(year: calendar.component(.year, from: now),
                                                         month: calendar.component(.month, from: now),
                                                         day: settings.monthlyResetDate)) ?? now
            } else {
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return calendar.date(from: DateComponents(year: calendar.component(.year, from: previousMonth),
                                                         month: calendar.component(.month, from: previousMonth),
                                                         day: settings.monthlyResetDate)) ?? now
            }
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
        let startOfPeriod = getStartOfCurrentPeriod()
        let activeSubscriptions = subscriptions.filter { $0.isActive && $0.startDate <= Date() }
        
        for subscription in activeSubscriptions {
            let hasExpenseThisPeriod = expenses.contains { expense in
                expense.comment.contains("Subscription: \(subscription.name)") &&
                expense.date >= startOfPeriod
            }
            
            if !hasExpenseThisPeriod {
                let subscriptionExpense = Expense(
                    amount: subscription.amount,
                    comment: "Subscription: \(subscription.name)",
                    date: startOfPeriod,
                    categoryId: subscription.categoryId
                )
                addExpense(subscriptionExpense)
            }
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
}