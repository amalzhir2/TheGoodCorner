//
//  APIError.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 18/09/2026.
//

import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed
    case network(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .serverError(let statusCode):
            return "The server responded with an error (code \(statusCode))."
        case .decodingFailed:
            return "The server response could not be understood."
        case .network(let message):
            return message
        }
    }
}
