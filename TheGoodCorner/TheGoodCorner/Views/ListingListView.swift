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
                Divider()
                searchSection
                categoriesSection
                Divider()
                listingsSection
            }
            .navigationTitle("The Good Corner")
            .task {
                if viewModel.state == .idle {
                    await viewModel.load()
                }
            }
        }
    }
        
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Rechercher une annonce…", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Effacer la recherche")
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.vertical, 8)
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
                    .accessibilityHint("Relance le chargement des annonces")
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityElement(children: .combine)
                
            case .empty:
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Aucun résultat")
                        .font(.headline)
                    Text("Aucune annonce ne correspond à « \(viewModel.searchQuery) »")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityElement(children: .combine)
                
            case .loaded:
                if viewModel.filteredListingsByCategory.isEmpty {
                    Text("Aucune annonce")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredListingsByCategory) { listing in
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
                            .onAppear {
                                if listing.id == viewModel.filteredListingsByCategory.last?.id && viewModel.selectedCategoryId == nil {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                        }
                        
                        if viewModel.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
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
