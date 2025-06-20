//
//  FavoritesManager.swift
//  RestaurantRecommender
//
//  Created by RENIK MULLER on 22/04/2025.
//

import Foundation

class FavoritesManager: ObservableObject {
    @Published private(set) var favorites: [Restaurant] = []

    private let favoritesKey = "favoritesKey"

    init() {
        loadFavorites()
    }

    func isFavorite(_ restaurant: Restaurant) -> Bool {
        return favorites.contains(where: { $0.id == restaurant.id })
    }

    func addFavorite(_ restaurant: Restaurant) {
        if !isFavorite(restaurant) {
            favorites.append(restaurant)
            saveFavorites()
        }
    }

    func removeFavorite(_ restaurant: Restaurant) {
        favorites.removeAll { $0.id == restaurant.id }
        saveFavorites()
    }

    func toggleFavorite(_ restaurant: Restaurant) {
        if isFavorite(restaurant) {
            removeFavorite(restaurant)
        } else {
            addFavorite(restaurant)
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let savedFavorites = try? JSONDecoder().decode([Restaurant].self, from: data) {
            favorites = savedFavorites
        }
    }
}

