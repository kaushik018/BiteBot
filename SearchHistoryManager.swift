//
//  SearchHistoryManager.swift
//  RestaurantRecommender
//
//  Created by RENIK MULLER on 22/04/2025.
//

import SwiftUI

class SearchHistoryManager: ObservableObject {
    @Published private(set) var searchHistory: [String] = []

    private let searchHistoryKey = "searchHistoryKey"

    init() {
        loadSearchHistory()
    }

    func addSearch(_ search: String) {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if !searchHistory.contains(trimmed) {
            searchHistory.insert(trimmed, at: 0) // Newest at the top
            saveSearchHistory()
        }
    }

    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
    }

    private func loadSearchHistory() {
        if let saved = UserDefaults.standard.stringArray(forKey: searchHistoryKey) {
            searchHistory = saved
        }
    }

    func clearSearchHistory() {
        searchHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: searchHistoryKey)
    }
}
