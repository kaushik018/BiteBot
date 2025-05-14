import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("pushNotifications") private var pushNotificationsEnabled = true
    @AppStorage("darkMode") private var darkModeEnabled = false
    @AppStorage("locationBased") private var locationBasedEnabled = true
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $themeManager.currentTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $pushNotificationsEnabled) {
                        SettingRow(
                            icon: "bell.fill",
                            iconColor: .blue,
                            title: "Push Notifications",
                            subtitle: "Get updates about new restaurants and offers"
                        )
                    }
                    
                    Toggle(isOn: $darkModeEnabled) {
                        SettingRow(
                            icon: "moon.fill",
                            iconColor: .purple,
                            title: "Dark Mode",
                            subtitle: "Switch between light and dark themes"
                        )
                    }
                    
                    Toggle(isOn: $locationBasedEnabled) {
                        SettingRow(
                            icon: "location.fill",
                            iconColor: .red,
                            title: "Location Services",
                            subtitle: "Get recommendations based on your location"
                        )
                    }
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        if let url = URL(string: "https://policies.google.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        SettingRow(
                            icon: "lock.fill",
                            iconColor: .gray,
                            title: "Privacy",
                            subtitle: "View our privacy policy"
                        )
                    }
                    
                        Button(action: {
                            if let url = URL(string: "https://policies.google.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                        SettingRow(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "Terms of Service",
                            subtitle: "Read our terms and conditions"
                        )
                    }
                    
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About")) {
                    SettingRow(
                        icon: "info.circle.fill",
                        iconColor: .blue,
                        title: "Version",
                        subtitle: "1.0.0"
                    )
                    
                    NavigationLink(destination: Text("Help Center")) {
                        SettingRow(
                            icon: "questionmark.circle.fill",
                            iconColor: .blue,
                            title: "Help & Support",
                            subtitle: "Get assistance and answers"
                        )
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Settings")
            preferredColorScheme(.light)
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        // Handle sign out
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 3)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
} 
