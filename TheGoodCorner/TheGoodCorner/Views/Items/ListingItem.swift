//
//  ListingItem.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 18/09/2026.
//

import SwiftUI

struct ListingItem: View {
    let listing: Listing
    let categoryName: String
    let baseURL: URL

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImage(url: listing.thumbnailURL(baseURL: baseURL))
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(listing.title)
                    .font(.headline)
                    .lineLimit(2)

                Spacer(minLength: 2)

                HStack(spacing: 8) {
                    Text(listing.formattedPrice)
                        .font(.subheadline.weight(.semibold))

                    if listing.isUrgent {
                        Text("Urgent")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red, in: Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}
