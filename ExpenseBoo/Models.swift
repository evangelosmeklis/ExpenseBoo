import Foundation
import SwiftUI

struct Expense: Identifiable, Codable, Equatable {
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

struct Income: Identifiable, Codable, Equatable {
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

struct Investment: Identifiable, Codable {
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

enum Currency: String, CaseIterable, Codable {
    case usd = "USD"
    case eur = "EUR" 
    case gbp = "GBP"
    case jpy = "JPY"
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case sek = "SEK"
    case nzd = "NZD"
    case mxn = "MXN"
    case sgd = "SGD"
    case hkd = "HKD"
    case nok = "NOK"
    case krw = "KRW"
    case inr = "INR"
    case brl = "BRL"
    case zar = "ZAR"
    
    var symbol: String {
        switch self {
        case .usd, .aud, .cad, .nzd, .mxn, .sgd, .hkd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy, .cny: return "¥"
        case .chf: return "CHF"
        case .sek: return "kr"
        case .nok: return "kr"
        case .krw: return "₩"
        case .inr: return "₹"
        case .brl: return "R$"
        case .zar: return "R"
        }
    }
    
    var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .chf: return "Swiss Franc"
        case .cny: return "Chinese Yuan"
        case .sek: return "Swedish Krona"
        case .nzd: return "New Zealand Dollar"
        case .mxn: return "Mexican Peso"
        case .sgd: return "Singapore Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .nok: return "Norwegian Krone"
        case .krw: return "South Korean Won"
        case .inr: return "Indian Rupee"
        case .brl: return "Brazilian Real"
        case .zar: return "South African Rand"
        }
    }
}

struct Settings: Codable, Equatable {
    var notificationsEnabled: Bool
    var dailyNotificationTime: Date
    var currency: Currency

    init() {
        self.notificationsEnabled = false
        self.dailyNotificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.currency = .usd
    }
}

struct MonthlyStats: Identifiable {
    let id = UUID()
    let month: Int
    let year: Int
    let income: Double
    let expenses: Double
    let investments: Double
    let profitLoss: Double

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let date = Calendar.current.date(from: DateComponents(year: year, month: month)) ?? Date()
        return formatter.string(from: date)
    }
}

struct ManualPL: Identifiable, Codable {
    let id: UUID
    let month: Int
    let year: Int
    let profitLoss: Double?  // For direct P/L entry
    let income: Double?      // For separate income entry
    let expenses: Double?    // For separate expense entry
    let investments: Double
    let note: String

    init(month: Int, year: Int, profitLoss: Double? = nil, income: Double? = nil, expenses: Double? = nil, investments: Double = 0, note: String = "") {
        self.id = UUID()
        self.month = month
        self.year = year
        self.profitLoss = profitLoss
        self.income = income
        self.expenses = expenses
        self.investments = investments
        self.note = note
    }

    // Computed property to get the effective P/L
    var effectiveProfitLoss: Double {
        if let directPL = profitLoss {
            return directPL
        } else {
            let incomeAmount = income ?? 0
            let expenseAmount = expenses ?? 0
            return incomeAmount - expenseAmount
        }
    }

    // Computed properties for display
    var effectiveIncome: Double {
        return income ?? 0
    }

    var effectiveExpenses: Double {
        return expenses ?? 0
    }
}

struct YearlyStats {
    let year: Int
    let totalIncome: Double
    let totalExpenses: Double
    let totalInvestments: Double
    let totalProfitLoss: Double
    let totalProfitLossWithoutInvestments: Double
    let averageMonthlyPL: Double
    let averageMonthlyPLWithoutInvestments: Double
    let bestMonth: String
    let worstMonth: String
    let bestMonthPL: Double
    let worstMonthPL: Double
}