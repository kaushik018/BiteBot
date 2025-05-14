import SwiftUI

enum AppTheme: String, CaseIterable {
    case defaultTheme = "Default"
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .defaultTheme
}

// Theme Colors
extension Color {
    // Primary brown color
    static let primaryBrown = Color(red: 0.335, green: 0.221, blue: 0.029)
    
    // Secondary brown color (lighter shade)
    static let secondaryBrown = Color(red: 0.765, green: 0.575, blue: 0.154)
    
    // Yellow gradient colors
    static let yellowGradientStart = Color(red: 1.0, green: 0.98, blue: 0.85) //Bright yellow
    static let yellowGradientEnd = Color(red: 1.0, green: 0.95, blue: 0.75)   //Orange-yellow
}
    
extension Color {
    static func themeBackground() -> LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [.yellowGradientEnd, .yellowGradientEnd]), startPoint: .top, endPoint: .bottom)
    }
    
    static func themeSecondaryBackground() -> Color {
        return .secondaryBrown
    }
    
    static func themeForeground() -> Color {
        return .primaryBrown
    }
    
    static func themeAccent() -> Color {
        return .primaryBrown
    }
    
    static func themeSecondaryAccent() -> Color {
        return .secondaryBrown
    }
}

// Theme Modifiers
struct GlowingBackground: ViewModifier {
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                Color.yellowGradientStart.opacity(0.2).opacity(intensity)
            )
    }
}

struct NeonBorder: ViewModifier {
    let width: CGFloat
    
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    Color.primaryBrown.opacity(0.8),
                    lineWidth: width
                )
                .blur(radius: 2)
        )
    }
}

extension View {
    func glowingBackground(intensity: Double = 0.5) -> some View {
        modifier(GlowingBackground(intensity: intensity))
    }
    
    func neonBorder(width: CGFloat = 1) -> some View {
        modifier(NeonBorder(width: width))
    }
} 
