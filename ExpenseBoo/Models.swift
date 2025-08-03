import Foundation
import SwiftUI

struct Expense: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var comment: String
    var date: Date
    var categoryId: UUID?
    
    init(amount: Double, comment: String, date: Date = Date(), categoryId: UUID? = nil) {
        self.id = UUID()
        self.amount = amount
        self.comment = comment
        self.date = date
        self.categoryId = categoryId
    }
}

struct Category: Identifiable, Codable {
    var id: UUID
    var name: String
    var color: Color
    
    init(name: String, color: Color = .blue) {
        self.id = UUID()
        self.name = name
        self.color = color
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        try container.encode(Double(red), forKey: .red)
        try container.encode(Double(green), forKey: .green)
        try container.encode(Double(blue), forKey: .blue)
        try container.encode(Double(alpha), forKey: .alpha)
    }
}

struct Income: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var date: Date
    var isMonthly: Bool
    
    init(amount: Double, date: Date = Date(), isMonthly: Bool = true) {
        self.id = UUID()
        self.amount = amount
        self.date = date
        self.isMonthly = isMonthly
    }
}

enum ResetType: String, CaseIterable, Codable {
    case payDay = "Pay Day"
    case monthlyDate = "Monthly Date"
    
    var displayName: String {
        return self.rawValue
    }
}

struct SavingGoal: Identifiable, Codable {
    var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var targetDate: Date
    var isGeneric: Bool
    
    init(name: String, targetAmount: Double, currentAmount: Double = 0, targetDate: Date, isGeneric: Bool = false) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.isGeneric = isGeneric
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var remainingAmount: Double {
        return max(targetAmount - currentAmount, 0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return max(days, 0)
    }
    
    var dailySavingNeeded: Double {
        guard daysRemaining > 0 else { return remainingAmount }
        return remainingAmount / Double(daysRemaining)
    }
}

struct Subscription: Identifiable, Codable {
    var id: UUID
    var name: String
    var amount: Double
    var categoryId: UUID?
    var isActive: Bool
    var startDate: Date
    
    init(name: String, amount: Double, categoryId: UUID? = nil, startDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.categoryId = categoryId
        self.isActive = true
        self.startDate = startDate
    }
}

struct Settings: Codable, Equatable {
    var resetType: ResetType
    var payDay: Int
    var monthlyResetDate: Int
    var notificationsEnabled: Bool
    var dailyNotificationTime: Date
    
    init() {
        self.resetType = .payDay
        self.payDay = 1
        self.monthlyResetDate = 1
        self.notificationsEnabled = false
        self.dailyNotificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
}