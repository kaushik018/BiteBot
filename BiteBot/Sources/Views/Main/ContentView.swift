import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            ChatbotView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 
