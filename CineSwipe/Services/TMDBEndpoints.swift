//
//  TMDBEndpoints.swift
//  CineSwipe
//

import Foundation

enum TMDBEndpoints {
    static var commonQuery: [URLQueryItem] {
        [
            URLQueryItem(name: "language", value: LocaleService.language),
            URLQueryItem(name: "region", value: LocaleService.region)
        ]
    }

    static func trendingWeek(page: Int = 1) -> (path: String, query: [URLQueryItem]) {
        ("trending/movie/week", commonQuery + [URLQueryItem(name: "page", value: "\(page)")])
    }

    static func popular(page: Int = 1) -> (path: String, query: [URLQueryItem]) {
        ("movie/popular", commonQuery + [URLQueryItem(name: "page", value: "\(page)")])
    }

    static func topRated(page: Int = 1) -> (path: String, query: [URLQueryItem]) {
        ("movie/top_rated", commonQuery + [URLQueryItem(name: "page", value: "\(page)")])
    }

    static func upcoming(page: Int = 1) -> (path: String, query: [URLQueryItem]) {
        ("movie/upcoming", commonQuery + [URLQueryItem(name: "page", value: "\(page)")])
    }

    static func discoverByGenre(_ genreId: Int, page: Int = 1) -> (path: String, query: [URLQueryItem]) {
        ("discover/movie",
         commonQuery + [
            URLQueryItem(name: "with_genres", value: "\(genreId)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "page", value: "\(page)")
         ])
    }

    static func movieDetail(id: Int) -> (path: String, query: [URLQueryItem]) {
        ("movie/\(id)",
         commonQuery + [
            URLQueryItem(name: "append_to_response", value: "credits,videos,watch/providers")
         ])
    }
}
