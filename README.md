# BiteBot 🍽️

**Your AI-Powered Restaurant Recommendation Assistant**

BiteBot is an intelligent iOS application that helps users discover the best nearby restaurants through an interactive AI chatbot interface. Built as part of a senior design project, BiteBot combines location-based recommendations, real-time weather updates, and personalized dining suggestions to create a seamless restaurant discovery experience.

## ✨ Features

### 🤖 AI-Powered Chatbot
- **Intelligent Conversations**: Ask for restaurant recommendations, cuisine preferences, or dining suggestions
- **Context-Aware Responses**: The chatbot understands your preferences and provides personalized suggestions
- **Natural Language Processing**: Communicate naturally with the AI assistant

### 📍 Location-Based Recommendations
- **Real-Time Location**: Uses your current location to find nearby restaurants
- **Google Places Integration**: Access to comprehensive restaurant data and reviews
- **Interactive Map View**: Visualize restaurant locations on an interactive map

### 🌤️ Weather-Aware Suggestions
- **Weather Integration**: Recommendations adapt based on current weather conditions
- **Seasonal Preferences**: Suggests appropriate dining options for different weather scenarios

### 🏪 Restaurant Details
- **Comprehensive Information**: View menus, ratings, hours, and contact details
- **Interactive Cards**: Swipe through restaurant recommendations in chat
- **Detailed Views**: Tap to explore full restaurant information

### 👤 User Experience
- **Search History**: Track and reuse previous searches
- **Favorites Management**: Save and organize your favorite restaurants
- **Profile Customization**: Personalize your dining preferences
- **Modern UI**: Clean, intuitive interface with smooth animations

## 🏗️ Project Structure

```
BiteBot/
├── Sources/
│   ├── Views/
│   │   ├── Authentication/     # Login, signup, password recovery
│   │   ├── Main/              # Main app views (map, tabs, content)
│   │   ├── Restaurant/        # Restaurant detail and card views
│   │   ├── Chat/              # AI chatbot interface
│   │   └── Profile/           # User profile and settings
│   ├── Models/                # Data models and structures
│   ├── Managers/              # State management and data handling
│   ├── Services/              # Location and external service integrations
│   ├── Utils/                 # Helper functions and utilities
│   └── Resources/             # Storyboards and launch screens
├── Backend/                   # Cloud functions and backend logic
└── RestaurantRecommender.xcodeproj/  # Xcode project files
```

## 🛠️ Tech Stack

### Frontend
- **SwiftUI**: Modern declarative UI framework
- **UIKit**: Traditional iOS UI components where needed
- **Core Location**: Location services and GPS functionality

### Backend & APIs
- **Firebase Firestore**: Real-time database and data storage
- **Google Places API**: Restaurant data and location services
- **Weather API**: Real-time weather information
- **Google Cloud Functions**: Serverless backend processing

### AI & Machine Learning
- **Custom Chatbot**: AI-powered restaurant recommendation engine
- **Natural Language Processing**: Understanding user queries
- **Context Management**: Maintaining conversation context

## 🚀 Getting Started

### Prerequisites
- **Xcode 14.0+** (Latest version recommended)
- **iOS 15.0+** deployment target
- **Firebase Account** with Firestore enabled
- **Google Places API Key**
- **Weather API Key**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/BiteBot.git
   cd BiteBot
   ```

2. **Open the project**
   ```bash
   open RestaurantRecommender.xcodeproj
   ```

3. **Configure API Keys**
   - Add your Firebase configuration to `AppDelegate.swift`
   - Configure Google Places API key in location services
   - Set up Weather API credentials

4. **Install Dependencies**
   - The project uses Swift Package Manager for dependencies
   - Dependencies will be automatically resolved in Xcode

5. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run the application

## 📱 Usage

### Getting Started
1. **Launch the app** and grant location permissions
2. **Sign up or log in** to your account
3. **Start chatting** with the AI assistant about restaurants
4. **Explore recommendations** on the map or in chat

### Key Features
- **Ask for recommendations**: "Find Italian restaurants near me"
- **Weather-based queries**: "What's good for a rainy day?"
- **Cuisine preferences**: "Show me sushi places with good ratings"
- **Save favorites**: Tap the heart icon to save restaurants
- **View details**: Tap on restaurant cards for full information

## 🔧 Configuration

### Environment Setup
```swift
// In AppDelegate.swift
import FirebaseCore

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}
```

### API Configuration
- **Firebase**: Add `GoogleService-Info.plist` to your project
- **Google Places**: Configure API key in location services
- **Weather API**: Set up API credentials in weather service

## 🎨 UI/UX Features

### Design System
- **Consistent Color Scheme**: Warm browns and earth tones
- **Modern Typography**: Clean, readable fonts
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Layout**: Adapts to different screen sizes

### Accessibility
- **VoiceOver Support**: Full accessibility compliance
- **Dynamic Type**: Supports system font scaling
- **High Contrast**: Works with accessibility settings

## 🔮 Future Enhancements

### Planned Features
- **User Profile Personalization**: Dietary restrictions and preferences
- **In-App Table Booking**: Direct restaurant reservations
- **Review Aggregation**: Sentiment analysis of restaurant reviews
- **Food Delivery Integration**: Order delivery through the app
- **Social Features**: Share recommendations with friends
- **Offline Mode**: Cached recommendations for offline use

### Technical Improvements
- **Performance Optimization**: Faster loading and smoother animations
- **Advanced AI**: More sophisticated recommendation algorithms
- **Push Notifications**: Personalized restaurant alerts
- **Analytics**: User behavior tracking and insights

## 🤝 Contributing

We welcome contributions to BiteBot! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines
- Follow Swift style guidelines
- Add comments for complex logic
- Write unit tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Senior Design Team**: For collaboration and support
- **University Faculty**: For guidance and mentorship
- **Open Source Community**: For the amazing tools and libraries
- **Firebase Team**: For the robust backend platform
- **Google Places API**: For comprehensive restaurant data

## 📞 Support

If you encounter any issues or have questions:

- **Create an issue** on GitHub
- **Check the documentation** in the code comments
- **Review the troubleshooting guide** (coming soon)

---

**Made with ❤️ by the BiteBot Team**

*Discover your next favorite restaurant with AI-powered recommendations!*

