//
//  PersistenceService.swift
//  CineSwipe
//

import Foundation

enum PersistenceService {
    static let favoritesKey = "cineswipe.favorites"
    static let watchlistKey = "cineswipe.watchlist"

    static func load(_ key: String,
                     defaults: UserDefaults = .standard) -> [MovieRef] {
        guard let data = defaults.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([MovieRef].self, from: data)) ?? []
    }

    static func save(_ refs: [MovieRef],
                     key: String,
                     defaults: UserDefaults = .standard) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(refs) else { return }
        defaults.set(data, forKey: key)
    }
}
