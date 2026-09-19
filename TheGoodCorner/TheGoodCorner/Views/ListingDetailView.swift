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
            VStack(alignment: .leading, spacing: 0) {
                imageSection
                contentSection
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private var imageSection: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: listing.thumbnailURL(baseURL: baseURL))
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipped()
                .accessibilityHidden(true)
            HStack {
                badgesRow
                Spacer()
            }
            .padding(16)
            .padding(.bottom, 32)
        }
    }
    
    private var badgesRow: some View {
        HStack(spacing: 8) {
            Text(categoryName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.blue, in: Capsule())
                .accessibilityLabel("Catégorie : \(categoryName)")
            
            
            if listing.isUrgent {
                Text("Urgent")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red, in: Capsule())
                    .accessibilityLabel("l'état de l'annonce est urgent")
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleAndPriceSection
            dateLabel
            Divider()
            descriptionSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .offset(y: -24)
    }
    
    private var titleAndPriceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(listing.title)
                .font(.title2.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            
            Text(listing.formattedPrice)
                .font(.title3.weight(.bold))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Prix : \(listing.formattedPrice)")
            
        }
    }
    
    private var dateLabel: some View {
        Label {
            Text("Publiée le \(listing.formattedDate)")
                .font(.footnote)
        } icon: {
            Image(systemName: "calendar")
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Publiée le \(listing.accessibilityFormattedDate)")
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Text(listing.description)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
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
