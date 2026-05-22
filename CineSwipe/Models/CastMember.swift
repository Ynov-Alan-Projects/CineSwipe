//
//  CastMember.swift
//  CineSwipe
//

import Foundation

struct CastMember: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int

    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case profilePath = "profile_path"
    }

    func profileURL(size: String = "w185") -> URL? {
        guard let path = profilePath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size)
            .appendingPathComponent(path)
    }
}

struct Credits: Codable, Sendable {
    let cast: [CastMember]
}
