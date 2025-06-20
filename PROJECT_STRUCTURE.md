# BiteBot Project Structure

This document provides a detailed overview of the BiteBot iOS application's organized folder structure.

## 📁 Root Directory

```
BiteBot/
├── Sources/                    # Main source code directory
├── Backend/                    # Backend and cloud functions
├── RestaurantRecommender.xcodeproj/  # Xcode project files
├── README.md                   # Main project documentation
└── PROJECT_STRUCTURE.md        # This file
```

## 📱 Sources Directory

The `Sources/` directory contains all the main application code, organized by functionality:

### 🎨 Views/
Contains all SwiftUI and UIKit view files, organized by feature:

#### Authentication/
- `AuthenticationView.swift` - Main login/signup interface
- `ForgotPasswordView.swift` - Password recovery screen
- `SignUpViewController.swift` - User registration view

#### Main/
- `ContentView.swift` - Root view with tab navigation
- `TabBarView.swift` - Custom tab bar implementation
- `MapView.swift` - Interactive map showing restaurants
- `ViewController.swift` - Main view controller

#### Restaurant/
- `RestaurantDetailView.swift` - Detailed restaurant information view
- `RestaurantCardView.swift` - Compact restaurant card component

#### Chat/
- `ChatbotView.swift` - AI chatbot interface and conversation UI

#### Profile/
- `ProfileView.swift` - User profile and account management
- `SettingsView.swift` - App settings and preferences

### 📊 Models/
Data models and structures:
- `ChatModels.swift` - Chat message models and restaurant data structures

### 🔧 Managers/
State management and data handling:
- `SearchHistoryManager.swift` - Manages user search history
- `FavoritesManager.swift` - Handles favorite restaurants
- `ThemeManager.swift` - App theming and appearance management

### 🌐 Services/
External service integrations:
- `LocationManager.swift` - GPS and location services
- `LocationViewController.swift` - Location permission handling

### 🛠️ Utils/
Helper functions and utilities:
- `Assets.swift` - Asset management and constants
- `Animations.swift` - Custom animations and transitions

### 📚 Resources/
UI resources and storyboards:
- `Main.storyboard` - Main storyboard file
- `LaunchScreen.storyboard` - App launch screen

### 🏗️ App Core/
Core application files:
- `AppDelegate.swift` - Application lifecycle management
- `SceneDelegate.swift` - Scene lifecycle management

## ☁️ Backend Directory

Contains backend and cloud functions:
- `cloud.js` - Google Cloud Functions for backend processing

## 🎯 Key Design Principles

### 1. **Separation of Concerns**
- Views are separated from business logic
- Managers handle state and data operations
- Services handle external integrations
- Utils provide reusable helper functions

### 2. **Feature-Based Organization**
- Related views are grouped together
- Each feature has its own subdirectory
- Clear boundaries between different app sections

### 3. **Scalability**
- Easy to add new features
- Clear structure for new developers
- Maintainable codebase organization

## 🔄 Migration Notes

If you're migrating from the old flat structure:

1. **Update Import Statements**: Some files may need updated import paths
2. **Xcode Project**: Update file references in the Xcode project
3. **Build Settings**: Ensure all files are included in the build target

## 📝 File Naming Conventions

- **Views**: `[Feature]View.swift` or `[Feature]ViewController.swift`
- **Models**: `[Feature]Models.swift`
- **Managers**: `[Feature]Manager.swift`
- **Services**: `[Feature]Service.swift` or `[Feature]Manager.swift`
- **Utils**: `[Feature].swift` (generic utilities)

## 🚀 Benefits of This Structure

1. **Easy Navigation**: Developers can quickly find relevant files
2. **Team Collaboration**: Clear ownership of different features
3. **Code Reusability**: Utils and services can be easily shared
4. **Maintenance**: Easier to maintain and update specific features
5. **Onboarding**: New developers can understand the codebase quickly

## 🔧 Customization

Feel free to adapt this structure based on your team's preferences:

- Add new feature directories as needed
- Reorganize files within directories
- Create additional utility categories
- Add documentation for specific features

---

*This structure is designed to scale with your project and make development more efficient.* 