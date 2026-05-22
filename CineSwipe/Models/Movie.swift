//
//  Movie.swift
//  Popcorn
//



import Foundation

struct Movie: Codable, Sendable, Identifiable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let title: String
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: Date?
    let softcore: Bool
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id, title
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case softcore, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(
        adult: Bool,
        backdropPath: String?,
        genreIDS: [Int],
        id: Int,
        title: String,
        originalLanguage: String,
        originalTitle: String,
        overview: String,
        popularity: Double,
        posterPath: String?,
        releaseDate: String?,
        softcore: Bool,
        video: Bool,
        voteAverage: Double,
        voteCount: Int
    ) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.genreIDS = genreIDS
        self.id = id
        self.title = title
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.overview = overview
        self.popularity = popularity
        self.posterPath = posterPath
        self.softcore = softcore
        self.video = video
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        
        if let releaseDate = releaseDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            self.releaseDate = formatter.date(from: releaseDate)
        } else {
            self.releaseDate = nil
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.adult = try c.decode(Bool.self, forKey: .adult)
        self.backdropPath = try c.decodeIfPresent(String.self, forKey: .backdropPath)
        self.genreIDS = try c.decode([Int].self, forKey: .genreIDS)
        self.id = try c.decode(Int.self, forKey: .id)
        self.title = try c.decode(String.self, forKey: .title)
        self.originalLanguage = try c.decode(String.self, forKey: .originalLanguage)
        self.originalTitle = try c.decode(String.self, forKey: .originalTitle)
        self.overview = try c.decode(String.self, forKey: .overview)
        self.popularity = try c.decode(Double.self, forKey: .popularity)
        self.posterPath = try c.decodeIfPresent(String.self, forKey: .posterPath)

        if let raw = try c.decodeIfPresent(String.self, forKey: .releaseDate), !raw.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            self.releaseDate = formatter.date(from: raw)
        } else {
            self.releaseDate = nil
        }

        self.softcore = try c.decodeIfPresent(Bool.self, forKey: .softcore) ?? false
        self.video = try c.decode(Bool.self, forKey: .video)
        self.voteAverage = try c.decode(Double.self, forKey: .voteAverage)
        self.voteCount = try c.decode(Int.self, forKey: .voteCount)
    }
}

extension Movie {
    var releaseYear: String {
        guard let date = releaseDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

extension Movie {
    enum PosterSize: String { case w185, w342, w500, original }

    func posterURL(_ size: PosterSize = .w342) -> URL? {
        guard let path = posterPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(path)
    }
    
    func backdropURL(_ size: PosterSize = .w342) -> URL? {
        guard let path = backdropPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(path)
    }
}
