//
//  ListingListView.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 18/09/2026.
//

import SwiftUI

struct ListingListView: View {
    @StateObject private var viewModel = ListingsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoriesSection
                Divider()
                listingsSection
            }
            .navigationTitle("The Good Corner")
            .task {
                await viewModel.load()
            }
        }
    }
    
    private var categoriesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories) { category in
                    CategoryItem(
                        title: category.name,
                        isSelected: viewModel.selectedCategoryId == category.id
                    ) {
                        if viewModel.selectedCategoryId == category.id {
                            viewModel.selectedCategoryId = nil
                        } else {
                            viewModel.selectedCategoryId = category.id
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    private var listingsSection: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Chargement…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .failed(let message):
                VStack(spacing: 12) {
                    Text("Une erreur est survenue")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Réessayer") {
                        Task { await viewModel.load() }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .loaded:
                if viewModel.filteredListingsByCategory.isEmpty {
                    Text("Aucune annonce")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.filteredListingsByCategory) { listing in
                        NavigationLink {
                            ListingDetailView(
                                listing: listing,
                                categoryName: viewModel.categoryName(for: listing.categoryId),
                                baseURL: APIClient.defaultBaseURL
                            )
                        } label: {
                            ListingItem(
                                listing: listing,
                                categoryName: viewModel.categoryName(for: listing.categoryId),
                                baseURL: APIClient.defaultBaseURL
                            )
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.load()
                    }
                }
            }
        }
    }
}

#Preview {
    ListingListView()
}
