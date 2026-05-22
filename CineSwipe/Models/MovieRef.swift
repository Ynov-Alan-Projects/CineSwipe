//
//  MovieRef.swift
//  CineSwipe
//

import Foundation

struct MovieRef: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: Date?
    let voteAverage: Double
    let addedAt: Date
}

extension MovieRef {
    init(from movie: Movie) {
        self.init(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            addedAt: Date()
        )
    }

    var releaseYear: String {
        guard let date = releaseDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }

    func posterURL(_ size: Movie.PosterSize = .w342) -> URL? {
        guard let path = posterPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(path)
    }
}
