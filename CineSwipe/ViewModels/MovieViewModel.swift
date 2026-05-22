//
//  MovieViewModel.swift
//  CineSwipe
//

import Foundation
import Observation

@Observable
final class MovieViewModel {
    private(set) var favorites: [MovieRef] = []
    private(set) var watchlist: [MovieRef] = []

    enum ListKind { case favorites, watchlist }

    init() {
        favorites = PersistenceService.load(PersistenceService.favoritesKey)
        watchlist = PersistenceService.load(PersistenceService.watchlistKey)
    }

    // MARK: - Queries

    func isFavorite(_ id: Int) -> Bool {
        favorites.contains { $0.id == id }
    }

    func isInWatchlist(_ id: Int) -> Bool {
        watchlist.contains { $0.id == id }
    }

    var savedIDs: Set<Int> {
        Set(favorites.map(\.id)).union(watchlist.map(\.id))
    }

    // MARK: - Mutations

    func toggleFavorite(_ movie: Movie) {
        if isFavorite(movie.id) {
            favorites.removeAll { $0.id == movie.id }
        } else {
            favorites.insert(MovieRef(from: movie), at: 0)
        }
        persistFavorites()
    }

    func toggleWatchlist(_ movie: Movie) {
        if isInWatchlist(movie.id) {
            watchlist.removeAll { $0.id == movie.id }
        } else {
            watchlist.insert(MovieRef(from: movie), at: 0)
        }
        persistWatchlist()
    }

    func addMovieToFavorite(_ movie: Movie) async throws {
        guard !isFavorite(movie.id) else { return }
        favorites.insert(MovieRef(from: movie), at: 0)
        persistFavorites()
    }

    func addMovieToWatchlist(_ movie: Movie) async throws {
        guard !isInWatchlist(movie.id) else { return }
        watchlist.insert(MovieRef(from: movie), at: 0)
        persistWatchlist()
    }

    func remove(id: Int, from list: ListKind) {
        switch list {
        case .favorites:
            favorites.removeAll { $0.id == id }
            persistFavorites()
        case .watchlist:
            watchlist.removeAll { $0.id == id }
            persistWatchlist()
        }
    }

    func clearFavorites() {
        favorites = []
        persistFavorites()
    }

    func clearWatchlist() {
        watchlist = []
        persistWatchlist()
    }

    // Stubs kept for compatibility with existing MovieSwipeView code paths.
    func refreshFavorites() async {}
    func refreshWatchlist() async {}

    // MARK: - Private

    private func persistFavorites() {
        PersistenceService.save(favorites, key: PersistenceService.favoritesKey)
    }

    private func persistWatchlist() {
        PersistenceService.save(watchlist, key: PersistenceService.watchlistKey)
    }
}
