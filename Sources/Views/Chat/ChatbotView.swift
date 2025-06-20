import SwiftUI

struct ChatbotView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var tabSelection = 1
    @State private var selectedRestaurant: Restaurant? = nil
    @EnvironmentObject var searchHistoryManager: SearchHistoryManager
    
    var body: some View {
        NavigationView {
            ZStack {
                //LinearGradient(gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                   // .edgesIgnoringSafeArea(.all)
                Color.white.ignoresSafeArea(.all)
                
                VStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message, tabSelection: $tabSelection)
                                        .id(message.id)
                                }
                                if viewModel.isLoading {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                            .padding()
                        }
                        .onChange(of: viewModel.messages.count) { _ in scrollToBottom(proxy: proxy) }
                        .onChange(of: viewModel.isLoading) { _ in scrollToBottom(proxy: proxy) }
                    }
                    
                    // Recent Searches Layout
                    if !searchHistoryManager.searchHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Recent Searches")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    searchHistoryManager.clearSearchHistory()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(6)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(searchHistoryManager.searchHistory, id: \.self) { search in
                                        Button(action: {
                                            viewModel.sendMessage(search)
                                        }) {
                                            HStack(spacing: 6) {
                                                Text(search)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14, weight: .medium))
                                                Image(systemName: "arrow.up.right")
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .font(.system(size: 12))
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(
                                                LinearGradient(gradient: Gradient(colors: [
                                                    Color(red: 139/255, green: 69/255, blue: 19/255),
                                                    Color(red: 160/255, green: 82/255, blue: 45/255)
                                                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                            .cornerRadius(20)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }

                    
                    ChatInputBar(text: $viewModel.messageText) {
                        if !viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            searchHistoryManager.addSearch(viewModel.messageText)
                            viewModel.sendMessage(viewModel.messageText)
                        }
                    }
                    .padding()
                }
            }
            .preferredColorScheme(.light)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        Image("Bitebotlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        Text("Bitebot")
                            .font(.custom("Helvetica Neue", size: 28).weight(.bold))
                            .foregroundColor(Color(red: 70/255, green: 35/255, blue: 8/255))
                    }
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isLoading {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    @Binding var tabSelection: Int
    var askBitebot: ((String) -> Void)? = nil
    var onRestaurantSelect: ((Restaurant) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            HStack {
                if message.isUser { Spacer() }
                
                Text(.init(message.content))
                    .padding(16)
                    .background(
                        Group {
                            if message.isUser {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 139/255, green: 69/255, blue: 19/255),
                                                                Color(red: 160/255, green: 82/255, blue: 45/255)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color(.systemGray6)
                            }
                        }
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if !message.isUser { Spacer() }
            }
            .padding(.horizontal, 12)
            
            if let restaurants = message.restaurants, !restaurants.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(restaurants) { restaurant in
                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant, askBitebot: askBitebot, tabSelection: $tabSelection)) {
                                RestaurantCardView(restaurant: restaurant)
                                    .frame(width: 280)
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $text)
                .padding(12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            
            Button(action: {
                onSend()
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .white)
                    .font(.system(size: 24))
                    .padding(8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 139/255, green: 69/255, blue: 19/255),
                                                      Color(red: 160/255, green: 82/255, blue: 45/255)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
    }
}

struct TypingIndicator: View {
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animate ? 1 : 0.5)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: animate)
            }
        }
        .onAppear { animate = true }
        .padding()
    }
}

struct ChatbotView_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotView()
    }
}
