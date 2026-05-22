//
//  CategorySource.swift
//  CineSwipe
//

import Foundation

enum CategorySource: Hashable, Identifiable {
    case trendingWeek
    case popular
    case topRated
    case upcoming
    case genre(id: Int, name: String)

    var id: String {
        switch self {
        case .trendingWeek: "trending_week"
        case .popular: "popular"
        case .topRated: "top_rated"
        case .upcoming: "upcoming"
        case .genre(let id, _): "genre_\(id)"
        }
    }

    var title: String {
        switch self {
        case .trendingWeek: "Tendances de la semaine"
        case .popular:      "Populaires"
        case .topRated:     "Mieux notés"
        case .upcoming:     "À venir"
        case .genre(_, let name): name
        }
    }

    func fetch(page: Int = 1) async throws -> [Movie] {
        let client = TMDBClient.shared
        switch self {
        case .trendingWeek: return try await client.trendingWeek(page: page).results
        case .popular:      return try await client.popular(page: page).results
        case .topRated:     return try await client.topRated(page: page).results
        case .upcoming:     return try await client.upcoming(page: page).results
        case .genre(let id, _): return try await client.discoverByGenre(id, page: page).results
        }
    }
}

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case failed(String)
}
