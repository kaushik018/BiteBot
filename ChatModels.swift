import SwiftUI
import Combine

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var associatedRestaurant: Restaurant?
    var restaurants: [Restaurant]?
    var isError: Bool = false

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Chat Response Model
struct ChatResponse {
    let fulfillmentMessages: [String]

    init?(json: [String: Any]) {
        // 1) Standard Dialogflow v2 structure: queryResult.fulfillmentMessages
        if let queryResult = json["queryResult"] as? [String: Any],
           let fulfillmentMessages = queryResult["fulfillmentMessages"] as? [[String: Any]] {
            self.fulfillmentMessages = fulfillmentMessages.compactMap { message in
                if let textDict = message["text"] as? [String: Any],
                   let texts = textDict["text"] as? [String],
                   let firstText = texts.first {
                    return firstText
                }
                return nil
            }
        }
        // 2) Top-level fulfillmentMessages (sometimes returned by custom webhook)
        else if let topFulfillmentMessages = json["fulfillmentMessages"] as? [[String: Any]] {
            self.fulfillmentMessages = topFulfillmentMessages.compactMap { message in
                if let textDict = message["text"] as? [String: Any],
                   let texts = textDict["text"] as? [String],
                   let firstText = texts.first {
                    return firstText
                }
                return nil
            }
        }
        // 3) Fallback to fulfillmentText if available
        else if let fulfillmentText = json["fulfillmentText"] as? String {
            self.fulfillmentMessages = [fulfillmentText]
        }
        // 4) Otherwise, log unexpected JSON and return nil
        else {
            print("ChatResponse initialization failed. Unexpected JSON structure: \(json)")
            return nil
        }
        
        // If no messages, fail gracefully.
        if self.fulfillmentMessages.isEmpty {
            print("ChatResponse initialization failed. fulfillmentMessages is empty: \(json)")
            return nil
        }
    }
}

// MARK: - Chat ViewModel
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var messageText: String = ""
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionId = UUID().uuidString
    
    init() {
        // Add an initial greeting from the bot.
        messages.append(ChatMessage(
            content: "Hello! I'm your restaurant recommendation assistant. How can I help you today?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        messageText = ""
        isLoading = true
        
        // Send the chat query to the server
        sendChatQuery(query: text, sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    // Process each fulfillment message
                    for responseText in response.fulfillmentMessages {
                        // Check if the response contains restaurant recommendations
                        if let restaurants = self?.extractRestaurants(from: responseText) {
                            let botMsg = ChatMessage(
                                content: responseText,
                                isUser: false,
                                timestamp: Date(),
                                restaurants: restaurants
                            )
                            self?.messages.append(botMsg)
                        } else {
                            let botMsg = ChatMessage(
                                content: responseText,
                                isUser: false,
                                timestamp: Date()
                            )
                            self?.messages.append(botMsg)
                        }
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                    let errorMsg = ChatMessage(
                        content: "Sorry, I encountered an error: \(error.localizedDescription)",
                        isUser: false,
                        timestamp: Date(),
                        isError: true
                    )
                    self?.messages.append(errorMsg)
                    print("Error details: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func extractRestaurants(from text: String) -> [Restaurant]? {
        // Check if the text contains restaurant data markers
        guard text.contains("**Here are some great restaurant options:**") else {
            return nil
        }
        
        // Split the text into lines
        let lines = text.components(separatedBy: .newlines)
        var restaurants: [Restaurant] = []
        var currentRestaurant: [String: Any] = [:]
        
        for line in lines {
            if line.contains("**") && line.contains("[") && line.contains("]") {
                // Start of a new restaurant
                if !currentRestaurant.isEmpty {
                    if let restaurant = createRestaurant(from: currentRestaurant) {
                        restaurants.append(restaurant)
                    }
                    currentRestaurant = [:]
                }
                
                // Extract restaurant name and link
                if let nameStart = line.range(of: "[")?.upperBound,
                   let nameEnd = line.range(of: "]")?.lowerBound {
                    let name = String(line[nameStart..<nameEnd])
                    currentRestaurant["name"] = name
                    
                    if let linkStart = line.range(of: "(")?.upperBound,
                       let linkEnd = line.range(of: ")")?.lowerBound {
                        let link = String(line[linkStart..<linkEnd])
                        currentRestaurant["link"] = link
                    }
                }
            } else if line.contains("Address:") {
                let address = line.replacingOccurrences(of: "📍 Address: ", with: "")
                currentRestaurant["address"] = address
            } else if line.contains("Rating:") {
                if let rating = Double(line.replacingOccurrences(of: "⭐ Rating: ", with: "").trimmingCharacters(in: .whitespaces)) {
                    currentRestaurant["rating"] = rating
                }
            } else if line.contains("Price:") {
                let priceString = line.replacingOccurrences(of: "💰 Price: ", with: "")
                let priceLevel = priceString.filter { $0 == "$" }.count
                currentRestaurant["price_level"] = priceLevel
            }
        }
        
        // Add the last restaurant if exists
        if !currentRestaurant.isEmpty {
            if let restaurant = createRestaurant(from: currentRestaurant) {
                restaurants.append(restaurant)
            }
        }
        
        return restaurants.isEmpty ? nil : restaurants
    }
    
    private func createRestaurant(from data: [String: Any]) -> Restaurant? {
        guard let name = data["name"] as? String,
              let rating = data["rating"] as? Double else {
            return nil
        }
        
        let address = data["address"] as? String ?? "Address not available"
        let link = data["link"] as? String ?? ""
        
        // Convert price_level to PriceLevel enum
        let priceLevel: PriceLevel
        if let price_level = data["price_level"] as? Int {
            switch price_level {
            case 1: priceLevel = .budget
            case 2: priceLevel = .moderate
            case 3: priceLevel = .expensive
            case 4: priceLevel = .luxury
            default: priceLevel = .moderate
            }
        } else {
            priceLevel = .moderate
        }
        
        return Restaurant(
            name: name,
            cuisine: "Indian", // Since we're specifically handling Indian restaurants
            rating: rating,
            image: "", // No image URL provided in the chat response
            priceLevel: priceLevel,
            atmosphere: [.casual], // Default atmosphere
            features: [.takeout], // Default features
            openingHours: OpeningHours(days: [
                .monday: DayHours(opening: "11:00", closing: "22:00"),
                .tuesday: DayHours(opening: "11:00", closing: "22:00"),
                .wednesday: DayHours(opening: "11:00", closing: "22:00"),
                .thursday: DayHours(opening: "11:00", closing: "22:00"),
                .friday: DayHours(opening: "11:00", closing: "23:00"),
                .saturday: DayHours(opening: "11:00", closing: "23:00"),
                .sunday: DayHours(opening: "11:00", closing: "21:00")
            ]),
            distance: 0.0, // Distance not provided in chat response
            isOpenNow: true, // Default to true since we don't have real-time data
            latitude: 41.6544,
            longitude: -83.5361
        )
    }
    
    private func sendChatQuery(query: String, sessionId: String, completion: @escaping (Result<ChatResponse, Error>) -> Void) {
        let urlString = ""
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build a minimal JSON payload with only the raw text and session ID.
        let payload: [String: Any] = [
            "text": query,
            "session": sessionId
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let chatResponse = ChatResponse(json: jsonObject) {
                    completion(.success(chatResponse))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON structure", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
