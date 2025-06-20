import SwiftUI

enum AppImages {
    static let defaultProfileImage = UIImage(systemName: "person.circle.fill")!
    static let defaultRestaurantImage = UIImage(systemName: "photo")!
    
    // Restaurant Images
    static let restaurant1 = "restaurant1"
    static let restaurant2 = "restaurant2"
    static let restaurant3 = "restaurant3"
    
    // Category Icons
    static let categoryIcons = [
        "Italian": "🍝",
        "Japanese": "🍱",
        "Indian": "🍛",
        "Mexican": "🌮",
        "Chinese": "🥢"
    ]
}

extension Color {
    static let appPrimary = Color.blue
    static let appSecondary = Color.gray.opacity(0.2)
    static let appBackground = Color(.systemBackground)
    static let appText = Color(.label)
    static let appGray = Color(.systemGray)
}

extension Image {
    static func restaurantPlaceholder() -> some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundColor(.gray.opacity(0.3))
    }
    
    static func profilePlaceholder() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundColor(.gray)
    }
} 
