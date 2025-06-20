import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var themeManager: ThemeManager
    var restaurants: [Restaurant]
    
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)
    private let iconColor = Color(red: 1.0, green: 0.9, blue: 0.7)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(1)
            
            ChatbotView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { newValue in
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        .accentColor(primaryBrown)
        // Add smooth transition animation
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
        // Add tab bar appearance customization
        .onAppear {
            let appearance = UITabBarAppearance()
            let blurEffect = UIBlurEffect(style: .regular)
            appearance.backgroundEffect = blurEffect
            appearance.backgroundColor = UIColor(primaryBrown)
            appearance.shadowColor = UIColor.clear
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(iconColor.opacity(0.7))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(iconColor.opacity(0.7))]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(iconColor)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(iconColor)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(restaurants: [])
            .environmentObject(ThemeManager())
            .environmentObject(UserSettings())
    }
} 
