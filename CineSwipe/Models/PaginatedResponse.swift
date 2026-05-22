//
//  PaginatedResponse.swift
//  CineSwipe
//

import Foundation

nonisolated struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
