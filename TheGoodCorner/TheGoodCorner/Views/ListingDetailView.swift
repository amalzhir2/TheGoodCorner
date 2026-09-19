//
//  ListingDetailView.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 19/09/2026.
//

import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    let categoryName: String
    let baseURL: URL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImage(
                    url: listing.thumbnailURL(baseURL: baseURL),
                    isDecorative: false
                )
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(categoryName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if listing.isUrgent {
                            Text("Urgent")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red, in: Capsule())
                        }
                    }
                    
                    Text(listing.title)
                        .font(.title2.weight(.bold))
                    
                    Text(listing.formattedPrice)
                        .font(.title3.weight(.semibold))
                    
                    Text("Posted \(listing.formattedDate)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Description:")
                        .font(.headline)
                    Text(listing.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(
            listing: Listing(
                id: 1,
                categoryId: 1,
                title: "Title",
                description: "A longer description of the item being sold, including condition and details.",
                price: 140,
                creationDate: .now,
                isUrgent: true,
                imagesUrl: nil
            ),
            categoryName: "Vehicule",
            baseURL: APIClient.defaultBaseURL
        )
    }
}
