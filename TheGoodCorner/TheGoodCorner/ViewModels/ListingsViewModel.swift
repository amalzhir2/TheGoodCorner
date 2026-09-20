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
        case empty
        case failed(String)
    }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var listings: [Listing] = []
    @Published private(set) var categories: [Category] = []
    @Published var selectedCategoryId: Int?
    @Published var searchQuery: String = ""
    @Published private(set) var currentPage: Int = 1
    @Published private(set) var hasMorePages: Bool = true
    @Published private(set) var isLoadingMore: Bool = false

    private let client: APIClientProtocol
    private let limit = 20

    // Gestion recherche
    private var searchCancellable: AnyCancellable?
    private var searchTask: Task<Void, Never>?
    private var currentQuery: String?

    init(client: APIClientProtocol? = nil) {
        self.client = client ?? APIClient()
        setupSearchDebounce()
    }
    
    var filteredListingsByCategory: [Listing] {
        guard let selectedCategoryId else { return listings }
        return listings.filter { $0.categoryId == selectedCategoryId }
    }

    private func setupSearchDebounce() {
        searchCancellable = $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.handleSearchChange(query)
            }
    }

    private func handleSearchChange(_ query: String) {
        // Annule la requête précédente si elle est encore en cours
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        currentQuery = trimmed.isEmpty ? nil : trimmed

        searchTask = Task { [weak self] in
            guard let self else { return }
            self.currentPage = 1
            self.hasMorePages = true
            self.state = .loading
            await self.fetchListings(page: 1, replacing: true)
        }
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
            let feed = try await client.fetchListings(page: page, limit: limit, query: currentQuery)

            // Si la tâche a été annulée entre-temps (nouvelle recherche lancée), on ignore le résultat
            guard !Task.isCancelled else { return }

            if replacing {
                listings = feed.items
            } else {
                listings.append(contentsOf: feed.items)
            }
            currentPage = feed.page
            hasMorePages = feed.hasMore
            state = listings.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            // Requête annulée volontairement : on ne modifie pas l'état
            return
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
