//
//  SceneDelegate.swift
//  RestaurantRecommender
//
//  Created by RENIK MULLER on 20/01/2025.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseStorage

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let primaryBrown = Color(red: 0.33575628219999998, green: 0.2216454944, blue: 0.029086147579999999)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create shared instances of environment objects
        let userSettings = UserSettings()
        let favoritesManager = FavoritesManager()
        let searchHistoryManager = SearchHistoryManager()
        
        // Configure window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Create root view
        let rootView = RootView()
            .environmentObject(userSettings)
            .environmentObject(favoritesManager)
            .environmentObject(searchHistoryManager)
        
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

// Root view to manage app state and navigation
struct RootView: View {
    @State private var isAuthenticated = false
    @State private var hasCompletedOnboarding = false
    @StateObject private var userSettings = UserSettings()
    @StateObject private var themeManager = ThemeManager()
    
    
    var body: some View {
        Group {
            if !isAuthenticated {
                AuthenticationView(isAuthenticated: $isAuthenticated)
            } else if !hasCompletedOnboarding {
                OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                TabBarView(restaurants: [])
            }
        }
        .onAppear {
            // Load saved state
            isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
            hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        .onChange(of: isAuthenticated) { newValue in
            UserDefaults.standard.set(newValue, forKey: "isAuthenticated")
            if !newValue {
                // Reset onboarding state when signing out
                hasCompletedOnboarding = false
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            }
        }
        .onChange(of: hasCompletedOnboarding) { newValue in
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
        .environmentObject(userSettings)
        .environmentObject(themeManager)
        // Listen for sign-out notification
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidSignOut"))) { _ in
            withAnimation {
                isAuthenticated = false
                hasCompletedOnboarding = false
            }
        }
    }
}

// UserSettings class with enhanced state management
class UserSettings: ObservableObject {
    @Published var isDarkMode = false
    @Published var isLoggedIn = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var profileImageURL: URL?
    @Published var profileImage: UIImage?
    
    // User preferences with default values
    @Published var selectedCuisines: Set<String> = []
    @Published var selectedDietary: Set<String> = []
    @Published var selectedDishes: Set<String> = []
    
    // Additional user preferences
    @Published var pricePreference: String = "moderate"
    @Published var distancePreference: Double = 5.0 // in kilometers
    @Published var ratingThreshold: Double = 4.0
    
    // Firebase auth state listener
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let storage = Storage.storage().reference()
    
    init() {
        loadPreferences()
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            DispatchQueue.main.async {
                self?.isLoggedIn = user != nil
                UserDefaults.standard.set(user != nil, forKey: "isAuthenticated")
                
                if let user = user {
                    self?.userName = user.displayName ?? ""
                    self?.userEmail = user.email ?? ""
                    if let photoURL = user.photoURL {
                        self?.profileImageURL = photoURL
                        self?.loadProfileImage(from: photoURL)
                    }
                } else {
                    self?.userName = ""
                    self?.userEmail = ""
                    self?.profileImageURL = nil
                    self?.profileImage = nil
                }
            }
        }
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.profileImage = image
                }
            }
        }.resume()
    }
    
    func updateProfileImage(_ image: UIImage, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser,
              let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
            return
        }
        
        let imageRef = storage.child("profile_images/\(user.uid).jpg")
        
        imageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]))
                    return
                }
                
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.photoURL = downloadURL
                
                changeRequest.commitChanges { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.profileImage = image
                        self?.profileImageURL = downloadURL
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func updateUserName(_ name: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        
        changeRequest.commitChanges { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    self?.userName = name
                }
                completion(error)
            }
        }
    }
    
    private func loadPreferences() {
        if let preferences = UserDefaults.standard.dictionary(forKey: "userPreferences") as? [String: Any] {
            selectedCuisines = Set(preferences["cuisines"] as? [String] ?? [])
            selectedDietary = Set(preferences["dietary"] as? [String] ?? [])
            selectedDishes = Set(preferences["dishes"] as? [String] ?? [])
            pricePreference = preferences["pricePreference"] as? String ?? "moderate"
            distancePreference = preferences["distancePreference"] as? Double ?? 5.0
            ratingThreshold = preferences["ratingThreshold"] as? Double ?? 4.0
        }
        
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        isLoggedIn = Auth.auth().currentUser != nil
    }
    
    func savePreferences() {
        let preferences: [String: Any] = [
            "cuisines": Array(selectedCuisines),
            "dietary": Array(selectedDietary),
            "dishes": Array(selectedDishes),
            "pricePreference": pricePreference,
            "distancePreference": distancePreference,
            "ratingThreshold": ratingThreshold
        ]
        
        UserDefaults.standard.set(preferences, forKey: "userPreferences")
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            userName = ""
            userEmail = ""
            profileImageURL = nil
            profileImage = nil
            UserDefaults.standard.set(false, forKey: "isAuthenticated")
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            
            // Clear user preferences
            selectedCuisines.removeAll()
            selectedDietary.removeAll()
            selectedDishes.removeAll()
            pricePreference = "moderate"
            distancePreference = 5.0
            ratingThreshold = 4.0
            savePreferences()
            
            NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

