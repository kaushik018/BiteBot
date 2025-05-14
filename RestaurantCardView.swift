import SwiftUI

struct RestaurantCardView: View {
    let restaurant: Restaurant
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Restaurant Image
            ZStack {
                if !restaurant.image.isEmpty {
                    Image(restaurant.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 160)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                // Restaurant Name and Rating
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Cuisine and Price Level
                HStack {
                    Text(restaurant.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(restaurant.priceDisplay)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Distance and Open Status
                HStack {
                    Text(String(format: "%.1f km", restaurant.distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(restaurant.isOpenNow ? "Open" : "Closed")
                        .font(.caption)
                        .foregroundColor(restaurant.isOpenNow ? .green : .red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(primaryBrown.opacity(0.1), lineWidth: 1)
        )
    }
}

struct RestaurantCardView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantCardView(restaurant: Restaurant(
            name: "Sample Restaurant",
            cuisine: "Italian",
            rating: 4.5,
            image: "restaurant1",
            priceLevel: .moderate,
            atmosphere: [.casual, .cozy],
            features: [.wifi, .parking],
            openingHours: OpeningHours(days: [
                .monday: DayHours(opening: "11:00", closing: "22:00"),
                .tuesday: DayHours(opening: "11:00", closing: "22:00"),
                .wednesday: DayHours(opening: "11:00", closing: "22:00"),
                .thursday: DayHours(opening: "11:00", closing: "22:00"),
                .friday: DayHours(opening: "11:00", closing: "23:00"),
                .saturday: DayHours(opening: "11:00", closing: "23:00"),
                .sunday: DayHours(opening: "11:00", closing: "21:00")
            ]),
            distance: 2.5,
            isOpenNow: true,
            latitude: 41.6544,
            longitude: -83.5361
        ))
        .padding()
    }
} 
