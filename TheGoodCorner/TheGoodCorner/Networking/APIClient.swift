//
//  APIClient.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 18/09/2026.
//

import Foundation

protocol APIClientProtocol {
    func fetchListings(page: Int?, limit: Int?, query: String?) async throws -> ListingFeed
    func fetchCategories() async throws -> [Category]
}

final class APIClient: APIClientProtocol {
    let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = APIClient.defaultBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    static let defaultBaseURL = URL(string: "http://localhost:8080")!

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func fetchListings(page: Int? = nil, limit: Int? = nil, query: String? = nil) async throws -> ListingFeed {
        let url = try Self.makeListingsURL(baseURL: baseURL, page: page, limit: limit, query: query)
        let data = try await load(url)
        do {
            return try Self.decoder.decode(ListingFeed.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    func fetchCategories() async throws -> [Category] {
        let url = baseURL.appendingPathComponent("categories")
        let data = try await load(url)
        do {
            return try Self.decoder.decode([Category].self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    private func load(_ url: URL) async throws -> Data {
        let response: (data: Data, response: URLResponse)
        do {
            response = try await session.data(from: url)
        } catch {
            throw APIError.network(error.localizedDescription)
        }
        guard let http = response.response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(statusCode: http.statusCode)
        }
        return response.data
    }

    static func makeListingsURL(baseURL: URL, page: Int?, limit: Int?, query: String?) throws -> URL {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("listings"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        var queryItems: [URLQueryItem] = []
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }
        if let limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        return url
    }
}
