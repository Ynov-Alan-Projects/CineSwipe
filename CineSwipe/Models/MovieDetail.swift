//
//  MovieDetail.swift
//  CineSwipe
//

import Foundation

nonisolated struct MovieDetail: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: Date?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let genres: [DetailGenre]
    let credits: Credits
    let videos: VideosResponse
    let watchProviders: WatchProvidersResponse

    nonisolated struct DetailGenre: Codable, Identifiable, Hashable, Sendable {
        let id: Int
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview, tagline, runtime, genres, credits, videos
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case watchProviders = "watch/providers"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(Int.self, forKey: .id)
        self.title = try c.decode(String.self, forKey: .title)
        self.originalTitle = try c.decode(String.self, forKey: .originalTitle)
        self.overview = try c.decode(String.self, forKey: .overview)
        self.tagline = try c.decodeIfPresent(String.self, forKey: .tagline)
        self.posterPath = try c.decodeIfPresent(String.self, forKey: .posterPath)
        self.backdropPath = try c.decodeIfPresent(String.self, forKey: .backdropPath)
        self.runtime = try c.decodeIfPresent(Int.self, forKey: .runtime)
        self.voteAverage = try c.decode(Double.self, forKey: .voteAverage)
        self.voteCount = try c.decode(Int.self, forKey: .voteCount)
        self.genres = try c.decode([DetailGenre].self, forKey: .genres)
        self.credits = try c.decode(Credits.self, forKey: .credits)
        self.videos = try c.decode(VideosResponse.self, forKey: .videos)
        self.watchProviders = try c.decode(WatchProvidersResponse.self, forKey: .watchProviders)

        self.releaseDate = try c.decodeIfPresent(Date.self, forKey: .releaseDate)
    }
}

extension MovieDetail {
    var releaseYear: String {
        guard let date = releaseDate else { return "N/A" }
        let year = Calendar(identifier: .gregorian).component(.year, from: date)
        return String(year)
    }

    func posterURL(_ size: Movie.PosterSize = .w500) -> URL? {
        guard let path = posterPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(path)
    }

    func backdropURL(size: String = "w780") -> URL? {
        guard let path = backdropPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size)
            .appendingPathComponent(path)
    }

    var officialYouTubeTrailer: Video? {
        videos.results
            .filter { $0.isYouTubeTrailer && $0.official }
            .first
            ?? videos.results.filter { $0.isYouTubeTrailer }.first
    }

    func providers(forRegion region: String) -> CountryProviders? {
        watchProviders.results[region]
    }
}
