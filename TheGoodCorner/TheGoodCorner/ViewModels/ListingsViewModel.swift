//
//  ListingsViewModel.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 17/09/2026.
//

import Foundation
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var categories: [Category] = []
    @Published var selectedCategoryId: Int?

    private let client: APIClientProtocol

    init(client: APIClientProtocol? = nil) {
        self.client = client ?? APIClient()
    }

    func load() async {
        state = .loading
        await fetchCategories()
        await fetchListings()
    }

    private func fetchCategories() async {
        do {
            categories = try await client.fetchCategories()
            state = .loaded
        } catch {
            categories = []
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
        }
    }

    private func fetchListings() async {
        do {
            let feed = try await client.fetchListings(page: nil, limit: nil, query: nil)
            listings = feed.items
            state = .loaded
        } catch {
            listings = []
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
        }
    }
}
