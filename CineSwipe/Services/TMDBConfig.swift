//
//  TMDBConfig.swift
//  Popcorn



import Foundation

enum TMDBConfig {
    static let baseURL    = URL(string: "https://api.themoviedb.org/3")!
    static let imageBase  = URL(string: "https://image.tmdb.org/t/p")!

    static let accountID  = "b48c06d36a7d01b12ba1a97ff59143f9"
    static let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiNDhjMDZkMzZhN2QwMWIxMmJhMWE5N2ZmNTkxNDNmOSIsIm5iZiI6MTc3OTQ0MTA1My4yMjg5OTk5LCJzdWIiOiI2YTEwMWQ5ZDhmODg4OTFhNjI0NTllZmMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.xW8Sxdp2B6o3EFiOLs_3UHcdhe_dhAveYs8nfjo6IGk"
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case http(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        "URL invalide"
        case .invalidResponse:   "Réponse invalide"
        case .http(let code):    "Erreur HTTP \(code)"
        case .decoding(let e):   "Décodage : \(e.localizedDescription)"
        case .transport(let e):  "Réseau : \(e.localizedDescription)"
        }
    }
}
