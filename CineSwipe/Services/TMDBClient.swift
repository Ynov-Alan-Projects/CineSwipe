//
//  TMDBClient.swift
//  Popcorn


import Foundation

actor TMDBClient {
    static let shared = TMDBClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        
        let dec = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        dec.dateDecodingStrategy = .formatted(formatter)
        self.decoder = dec
    }
    
    func get<T: Decodable>(_ path: String,
                           query: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(
            url: TMDBConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = query
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(TMDBConfig.bearerToken)",
                         forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse
            else { throw APIError.invalidResponse }
            guard (200..<300).contains(http.statusCode)
            else { throw APIError.http(http.statusCode) }
            
            do { return try decoder.decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        } catch let e as APIError {
            throw e
        } catch {
            throw APIError.transport(error)
        }
    }
    
    func post<T: Decodable>(_ path: String,
                            query: [URLQueryItem] = [],
                            body: Encodable) async throws -> T {
        var components = URLComponents(
            url: TMDBConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = query
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(TMDBConfig.bearerToken)",
                         forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse
            else { throw APIError.invalidResponse }
            guard (200..<300).contains(http.statusCode)
            else { throw APIError.http(http.statusCode) }
            
            do { return try decoder.decode(T.self, from: data) }
            catch { throw APIError.decoding(error) }
        } catch let e as APIError {
            throw e
        } catch {
            throw APIError.transport(error)
        }
    }

    // MARK: - Typed endpoints

    func trendingWeek(page: Int = 1) async throws -> PaginatedResponse<Movie> {
        let (path, query) = TMDBEndpoints.trendingWeek(page: page)
        return try await get(path, query: query)
    }

    func popular(page: Int = 1) async throws -> PaginatedResponse<Movie> {
        let (path, query) = TMDBEndpoints.popular(page: page)
        return try await get(path, query: query)
    }

    func topRated(page: Int = 1) async throws -> PaginatedResponse<Movie> {
        let (path, query) = TMDBEndpoints.topRated(page: page)
        return try await get(path, query: query)
    }

    func upcoming(page: Int = 1) async throws -> PaginatedResponse<Movie> {
        let (path, query) = TMDBEndpoints.upcoming(page: page)
        return try await get(path, query: query)
    }

    func discoverByGenre(_ genreId: Int, page: Int = 1) async throws -> PaginatedResponse<Movie> {
        let (path, query) = TMDBEndpoints.discoverByGenre(genreId, page: page)
        return try await get(path, query: query)
    }

    func movieDetail(id: Int) async throws -> MovieDetail {
        let (path, query) = TMDBEndpoints.movieDetail(id: id)
        return try await get(path, query: query)
    }
}
