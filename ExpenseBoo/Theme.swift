//
//  Theme.swift
//  ExpenseBoo
//
//  Tech-inspired theme with vibrant colors and monospace fonts
//

import SwiftUI

// MARK: - Color Extension for Adaptive Colors
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            @unknown default:
                return UIColor(light)
            }
        })
    }
}

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Vibrant tech colors
        static let neonGreen = Color(red: 0.0, green: 1.0, blue: 0.5)
        static let electricCyan = Color(red: 0.0, green: 0.9, blue: 1.0)
        static let vibrantPurple = Color(red: 0.6, green: 0.2, blue: 1.0)
        static let techOrange = Color(red: 1.0, green: 0.4, blue: 0.0)
        static let hotPink = Color(red: 1.0, green: 0.0, blue: 0.6)
        static let digitalYellow = Color(red: 1.0, green: 0.9, blue: 0.0)

        // Semantic colors
        static let income = neonGreen
        static let expense = hotPink
        static let investment = vibrantPurple
        static let profit = neonGreen
        static let loss = techOrange

        // Adaptive background colors
        static let cardBackground = Color(
            light: Color(red: 0.95, green: 0.95, blue: 0.97),
            dark: Color(red: 0.08, green: 0.08, blue: 0.12)
        )
        static let primaryBackground = Color(
            light: Color(red: 0.98, green: 0.98, blue: 0.99),
            dark: Color(red: 0.05, green: 0.05, blue: 0.08)
        )
        static let secondaryBackground = Color(
            light: Color(red: 0.92, green: 0.92, blue: 0.95),
            dark: Color(red: 0.12, green: 0.12, blue: 0.18)
        )

        // Adaptive text colors
        static let primaryText = Color(
            light: Color(red: 0.1, green: 0.1, blue: 0.1),
            dark: Color(red: 0.95, green: 0.95, blue: 0.95)
        )
        static let secondaryText = Color(
            light: Color(red: 0.4, green: 0.4, blue: 0.4),
            dark: Color(red: 0.7, green: 0.7, blue: 0.7)
        )

        // Border colors
        static let borderGlow = electricCyan.opacity(0.5)
        static let accentBorder = vibrantPurple.opacity(0.7)
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Monospace/typewriter style fonts
        static let mono = "Menlo"
        static let monoDigital = "SF Mono" // Digital/tech font for numbers
        
        static func title(_ size: CGFloat = 28) -> Font {
            .custom(monoDigital, size: size).weight(.heavy)
        }
        
        static func headline(_ size: CGFloat = 18) -> Font {
            .custom(monoDigital, size: size).weight(.bold)
        }
        
        static func body(_ size: CGFloat = 15) -> Font {
            .custom(mono, size: size).weight(.regular)
        }
        
        static func caption(_ size: CGFloat = 12) -> Font {
            .custom(mono, size: size).weight(.light)
        }
        
        static func number(_ size: CGFloat = 15) -> Font {
            .custom(monoDigital, size: size).weight(.semibold)
        }
    }
    
    // MARK: - Card Styles
    struct CardStyle: ViewModifier {
        var glowColor: Color = AppTheme.Colors.borderGlow
        
        func body(content: Content) -> some View {
            content
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(glowColor, lineWidth: 1.5)
                )
                .shadow(color: glowColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Button Styles
    struct TechButtonStyle: ViewModifier {
        var color: Color
        var isDestructive: Bool = false
        
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.body())
                .foregroundColor(isDestructive ? .white : color)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    isDestructive ? color.opacity(0.2) : color.opacity(0.15)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1.5)
                )
        }
    }
}

// MARK: - View Extensions
extension View {
    func techCard(glowColor: Color = AppTheme.Colors.borderGlow) -> some View {
        self.modifier(AppTheme.CardStyle(glowColor: glowColor))
    }
    
    func techButton(color: Color, isDestructive: Bool = false) -> some View {
        self.modifier(AppTheme.TechButtonStyle(color: color, isDestructive: isDestructive))
    }
}

// MARK: - Custom TextField Style
struct TechTextFieldStyle: TextFieldStyle {
    var color: Color = AppTheme.Colors.electricCyan
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTheme.Fonts.body())
            .padding(12)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            )
    }
}

