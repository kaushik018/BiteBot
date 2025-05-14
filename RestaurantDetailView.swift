import SwiftUI
import MapKit
import CoreLocation

struct Review: Identifiable {
    let id = UUID()
    let userName: String
    let rating: Double
    let comment: String
    let date: Date
}

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    var askBitebot: ((String) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ChatViewModel()
    @State private var isFavorite = false
    @State private var selectedImageIndex = 0
    
    //to switch to maps for get directions
    @Binding var tabSelection: Int
    
    @StateObject private var photoFetcher = PhotoFetcher()
    
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    let sampleReviews = [
        Review(userName: "Sarah M.", rating: 4.5, comment: "Amazing food and atmosphere! The service was excellent.", date: Date().addingTimeInterval(-86400)),
        Review(userName: "Mike R.", rating: 5.0, comment: "Best restaurant in town. Must try their signature dishes!", date: Date().addingTimeInterval(-172800)),
        Review(userName: "Emily L.", rating: 4.0, comment: "Great experience overall. Will definitely come back.", date: Date().addingTimeInterval(-259200))
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Restaurant Image or Placeholder
                /*ZStack {
                    if !restaurant.image.isEmpty {
                        Image(restaurant.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(height: 200)
                .clipped()*/
                // Restaurant Image from Google Places
                if let photoReference = photoFetcher.photoReference {
                    let imageURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=AIzaSyABUVWReZht_n56j5WL0ayEJHpYmWhT4"
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                    .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                    }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Restaurant Name and Rating
                    HStack {
                        Text(restaurant.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", restaurant.rating))
                        }
                    }
                    
                    // Price and Distance
                    HStack {
                        Text(restaurant.priceDisplay)
                        Text("•")
                        Text(String(format: "%.1f km", restaurant.distance))
                    }
                    .foregroundColor(.secondary)
                    
                    // Open Status and Get Directions
                    HStack(spacing: 12) {
                        Text(restaurant.isOpenNow ? "Open Now" : "Closed")
                            .foregroundColor(restaurant.isOpenNow ? .green : .red)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(restaurant.isOpenNow ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                            )
                    }
                    
                    // Ask Chatbot Button
                    Button(action: {
                        let message = "Tell me more about \(restaurant.name). What are their specialties and what do people recommend?"
                        //viewModel.sendMessage(message)
                        askBitebot?(message)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "message")
                            Text("Ask Bitebot about this restaurant")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top, 8)
                    
                    // Quick Questions Section
                    Text("Quick Questions")
                        .font(.headline)
                        .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        quickQuestionButton("Can you show the menu?")
                        quickQuestionButton("What is the price range?")
                        quickQuestionButton("What are the opening hours?")
                        quickQuestionButton("Where is it located?")
                        quickQuestionButton("What is the rating?")
                    }
                    .padding(.horizontal)
                
                    // Chat Response
                    /*if !viewModel.messages.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                if !message.isUser {
                                    Text(message.content)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }*/
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: favoritesManager.isFavorite(restaurant) ? "heart.fill" : "heart").foregroundColor(.red)
                }
                Button(action: {
                    // Share restaurant
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            photoFetcher.fetchPhotoReference(for: restaurant.name)
        }
    }
    
    // MARK: - Geocode the Address and Set Directions
    /*private func getDirections() {
        guard let address = restaurant.address else {
            print("No address available for this restaurant.")
            return
        }
            
        geocodeAddress(address: address) { coordinate in
            if let coordinate = coordinate {
                mapViewModel.setDestination(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    name: restaurant.name
                )
                tabSelection = 0
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Failed to geocode address: \(address)")
            }
        }
    }
    
    private func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                    completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }*/
    
    private func quickQuestionButton(_ question: String) -> some View {
        Button(action: {
            openGoogleBasedOnQuestion(question)
        }) {
            Text(question)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color(red: 0.34, green: 0.22, blue: 0.03))
                .cornerRadius(10)
        }
    }
    
    private func openGoogleBasedOnQuestion(_ question: String) {
        let baseName = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var searchQuery = ""

        switch question {
        case "Can you show the menu?":
            searchQuery = "\(baseName)+menu"
        case "What is the price range?":
            searchQuery = "\(baseName)+price+range"
        case "What are the opening hours?":
            searchQuery = "\(baseName)+hours"
        case "Where is it located?":
            searchQuery = "https://www.google.com/maps/search/?api=1&query=\(baseName)" // Direct maps
        case "What is the rating?":
            searchQuery = "\(baseName)+reviews"
        default:
            searchQuery = "\(baseName)"
        }

        let fullURL: URL
        if question == "Where is it located?" {
            fullURL = URL(string: searchQuery)!
        } else {
            fullURL = URL(string: "https://www.google.com/search?q=\(searchQuery)")!
        }
        
        UIApplication.shared.open(fullURL)
    }
    
    private func toggleFavorite() {
        if favoritesManager.isFavorite(restaurant) {
            favoritesManager.removeFavorite(restaurant)
        } else {
            favoritesManager.addFavorite(restaurant)
        }
    }
}

struct InfoItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(.gray)
    }
}

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.userName)
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", review.rating))
                }
            }
            
            Text(review.comment)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(review.date, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
            
            Divider()
        }
    }
}

// Preview Provider
struct RestaurantDetailView_Previews: PreviewProvider {
    @State static var tabSelection = 0
    static var previews: some View {
        RestaurantDetailView(restaurant: Restaurant(
            name: "Sample Restaurant",
            cuisine: "Italian",
            rating: 4.5,
            image: "",
            priceLevel: .moderate,
            atmosphere: [.casual],
            features: [.wifi],
            openingHours: OpeningHours(days: [:]),
            distance: 1.2,
            isOpenNow: true,
            address: "2247 S Reynolds Rd, Toledo, OH 43614",
            latitude: 41.6544,
            longitude: -83.5361
        ),
                             askBitebot: { _ in },
                             tabSelection: $tabSelection
        )
        .environmentObject(FavoritesManager())
    }
} 
