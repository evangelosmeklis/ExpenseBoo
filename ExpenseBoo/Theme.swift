//
//  Theme.swift
//  ExpenseBoo
//
//  Modern Premium Theme with Glassmorphism and Rounded Typography
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

// MARK: - Linear Gradient Extension
extension LinearGradient {
    static let primaryBackground = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.1, blue: 0.2), // Deep Indigo
            Color(red: 0.05, green: 0.05, blue: 0.1)  // Almost Black
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let incomeCard = LinearGradient(
        gradient: Gradient(colors: [
            Color.teal.opacity(0.8),
            Color.green.opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let expenseCard = LinearGradient(
        gradient: Gradient(colors: [
            Color.pink.opacity(0.8),
            Color.red.opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // New Modern Palette (Defined first for self-reference)
        static let emerald = Color(red: 0.2, green: 0.8, blue: 0.5)
        static let skyBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
        static let royalPurple = Color(red: 0.5, green: 0.3, blue: 0.9)
        static let sunsetOrange = Color(red: 1.0, green: 0.5, blue: 0.3)
        static let rosePink = Color(red: 1.0, green: 0.3, blue: 0.5)
        static let sunflower = Color(red: 1.0, green: 0.8, blue: 0.2)
        
        // Modern Palette Mapped to Old Names for Compatibility
        static let neonGreen = emerald
        static let electricCyan = skyBlue
        static let vibrantPurple = royalPurple
        static let techOrange = sunsetOrange
        static let hotPink = rosePink
        static let digitalYellow = sunflower
        

        // Semantic colors
        static let income = emerald
        static let expense = rosePink
        static let investment = royalPurple
        static let profit = emerald
        static let loss = sunsetOrange

        // Adaptive background colors
        static let cardBackground = Color(
            light: Color.white,
            dark: Color(red: 0.12, green: 0.12, blue: 0.15)
        )
        
        static let primaryBackground = Color(
            light: Color(red: 0.96, green: 0.96, blue: 0.98),
            dark: Color(red: 0.05, green: 0.05, blue: 0.08)
        )
        
        static let secondaryBackground = Color(
            light: Color(red: 0.92, green: 0.92, blue: 0.94),
            dark: Color(red: 0.15, green: 0.15, blue: 0.2)
        )

        // Adaptive text colors
        static let primaryText = Color(
            light: Color(red: 0.1, green: 0.1, blue: 0.15),
            dark: Color(red: 0.98, green: 0.98, blue: 1.0)
        )
        
        static let secondaryText = Color(
            light: Color(red: 0.5, green: 0.5, blue: 0.6),
            dark: Color(red: 0.6, green: 0.6, blue: 0.7)
        )

        // Border colors (Kept for compatibility, but made subtle)
        static let borderGlow = skyBlue.opacity(0.3)
        static let accentBorder = royalPurple.opacity(0.3)
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Mapped to System Rounded
        static let mono = "System Rounded" // Placeholder string, usage below implies Font
        static let monoDigital = "System Rounded" 
        
        static func title(_ size: CGFloat = 34) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func headline(_ size: CGFloat = 20) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }
        
        static func body(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        
        static func caption(_ size: CGFloat = 13) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
        
        static func number(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
    }
    
    // MARK: - Card Styles
    struct CardStyle: ViewModifier {
        var glowColor: Color = AppTheme.Colors.borderGlow // Param kept for API compatibility, unused in new style
        
        func body(content: Content) -> some View {
            content
                .background(.ultraThinMaterial)
                .background(AppTheme.Colors.cardBackground.opacity(0.5)) // Fallback/Tint
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Button Styles
    struct TechButtonStyle: ViewModifier {
        var color: Color
        var isDestructive: Bool = false
        
        func body(content: Content) -> some View {
            content
                .font(AppTheme.Fonts.body())
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    isDestructive ? Color.red : color
                )
                .cornerRadius(30) // Pill shape
                .shadow(color: (isDestructive ? Color.red : color).opacity(0.4), radius: 8, x: 0, y: 4)
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
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

