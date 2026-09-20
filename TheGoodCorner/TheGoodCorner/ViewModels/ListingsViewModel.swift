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
    @Published private(set) var currentPage: Int = 1
    @Published private(set) var hasMorePages: Bool = true
    @Published private(set) var isLoadingMore: Bool = false

    private let client: APIClientProtocol
    private let limit = 20

    init(client: APIClientProtocol? = nil) {
        self.client = client ?? APIClient()
    }
    
    var filteredListingsByCategory: [Listing] {
        guard let selectedCategoryId else { return listings }
        return listings.filter { $0.categoryId == selectedCategoryId }
    }

    func load() async {
        if state != .loaded {
            state = .loading
        }
        currentPage = 1
        hasMorePages = true
        await fetchCategories()
        await fetchListings(page: currentPage, replacing: true)
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
    
    func categoryName(for id: Int) -> String {
        categories.first(where: { $0.id == id })?.name ?? ""
    }

    private func fetchListings(page: Int, replacing: Bool) async {
        do {
            let feed = try await client.fetchListings(page: page, limit: limit, query: nil)
            if replacing {
                listings = feed.items
            } else {
                listings.append(contentsOf: feed.items)
            }
            currentPage = feed.page
            hasMorePages = feed.hasMore
            state = .loaded
        } catch {
            listings = []
            state = .failed((error as? LocalizedError)?.errorDescription ?? "Something went wrong.")
        }
    }
    
    func loadNextPage() async {
        guard hasMorePages, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        await fetchListings(page: currentPage + 1, replacing: false)
    }
}
