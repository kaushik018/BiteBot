import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings
    @State private var selectedTab = 0
    @State private var isEditingProfile = false
    @State private var showImagePicker = false
    @State private var showSignOutAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var tempName: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    
    // Settings States
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var locationEnabled = true
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let profileImage = userSettings.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(primaryBrown, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(primaryBrown)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(primaryBrown, lineWidth: 2))
                            }
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    userSettings.updateProfileImage(image) { error in
                                        if let error = error {
                                            errorMessage = error.localizedDescription
                                            showErrorAlert = true
                                        }
                                    }
                                }
                            }
                        }
                        
                        if isEditingProfile {
                            TextField("Name", text: $tempName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        } else {
                            Text(userSettings.userName.isEmpty ? "Guest User" : userSettings.userName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(userSettings.userEmail)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    
                    // Quick Actions
                   /* HStack(spacing: 30) {
                        QuickActionButton(title: "Favorites", icon: "heart.fill", count: "12")
                        QuickActionButton(title: "Reviews", icon: "star.fill", count: "28")
                        QuickActionButton(title: "Points", icon: "crown.fill", count: "350")
                    }
                    .padding(.horizontal)*/
                    
                    // Profile Sections
                    VStack(spacing: 0) {
                        NavigationLink(destination: FavoritesView()) {
                            ProfileRowLink(icon: "heart.fill", title: "My Favorites", color: .pink)
                        }
                        
                        NavigationLink(destination: OrderHistoryView()) {
                            ProfileRowLink(icon: "clock.fill", title: "Order History", color: .blue)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            ProfileRowLink(icon: "gearshape.fill", title: "Settings", color: .gray)
                        }
                        
                        Button(action: { showSignOutAlert = true }) {
                            ProfileRowLink(icon: "arrow.right.square.fill", title: "Sign Out", color: .red)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .preferredColorScheme(.light)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button(isEditingProfile ? "Done" : "Edit") {
                if isEditingProfile {
                    // Save changes
                    userSettings.updateUserName(tempName) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                } else {
                    // Start editing
                    tempName = userSettings.userName
                }
                isEditingProfile.toggle()
            })
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    userSettings.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let count: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
            Text(count)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ProfileRowLink: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct SettingsSection: View {
    @Binding var notificationsEnabled: Bool
    @Binding var darkModeEnabled: Bool
    @Binding var locationEnabled: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsRow(
                title: "Push Notifications",
                icon: "bell.fill",
                iconColor: .blue
            ) {
                Toggle("", isOn: $notificationsEnabled)
            }
            
            Divider()
            
            SettingsRow(
                title: "Dark Mode",
                icon: "moon.fill",
                iconColor: .purple
            ) {
                Toggle("", isOn: $darkModeEnabled)
            }
            
            Divider()
            
            SettingsRow(
                title: "Location Services",
                icon: "location.fill",
                iconColor: .red
            ) {
                Toggle("", isOn: $locationEnabled)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            content
        }
        .padding()
    }
}

struct OrderHistorySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Orders")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(0..<3) { _ in
                OrderRow()
            }
        }
    }
}

struct OrderRow: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Restaurant Name")
                    .font(.headline)
                Spacer()
                Text("$24.99")
                    .fontWeight(.semibold)
            }
            
            Text("2 items • Yesterday")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct FavoritesSection: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(0..<4) { _ in
                FavoriteRestaurantCard()
            }
        }
        .padding()
    }
}

struct FavoriteRestaurantCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            Text("Restaurant Name")
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("4.5")
                    .font(.subheadline)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(ThemeManager())
    }
}

// Additional Views (to be implemented in separate files)
struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedRestaurant: Restaurant?

        var body: some View {
            NavigationView {
            List(favoritesManager.favorites) { restaurant in
                Button(action: {
                    selectedRestaurant = restaurant
                }) {
                    VStack(alignment: .leading) {
                        Text(restaurant.name)
                            .font(.headline)
                        Text(restaurant.cuisine)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("My Favorites")
            .background(
                NavigationLink(
                    destination: Group {
                        if let selected = selectedRestaurant {
                            RestaurantDetailView(
                                restaurant: selected,
                                askBitebot: nil,
                                tabSelection: .constant(1)
                            )
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: Binding(
                        get: { selectedRestaurant != nil },
                        set: { if !$0 { selectedRestaurant = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
}

struct OrderHistoryView: View {
    var body: some View {
        Text("Order History")
            .navigationTitle("Order History")
    }
} 
