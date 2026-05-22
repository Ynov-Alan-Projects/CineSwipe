//
//  WatchProvider.swift
//  CineSwipe
//

import Foundation

struct WatchProvider: Codable, Identifiable, Hashable, Sendable {
    let providerId: Int
    let providerName: String
    let logoPath: String?

    var id: Int { providerId }

    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
    }

    func logoURL(size: String = "w92") -> URL? {
        guard let path = logoPath else { return nil }
        return TMDBConfig.imageBase
            .appendingPathComponent(size)
            .appendingPathComponent(path)
    }
}

struct CountryProviders: Codable, Sendable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
}

struct WatchProvidersResponse: Codable, Sendable {
    let results: [String: CountryProviders]
}
