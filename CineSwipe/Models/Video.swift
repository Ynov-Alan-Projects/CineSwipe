//
//  Video.swift
//  CineSwipe
//

import Foundation

nonisolated struct Video: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool

    var isYouTubeTrailer: Bool {
        site == "YouTube" && type == "Trailer"
    }

    var youtubeEmbedURL: URL? {
        URL(string: "https://www.youtube.com/embed/\(key)")
    }
}

nonisolated struct VideosResponse: Codable, Sendable {
    let results: [Video]
}
