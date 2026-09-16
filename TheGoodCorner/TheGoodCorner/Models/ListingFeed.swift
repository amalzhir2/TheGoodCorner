//
//  ListingFeed.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 17/09/2026.
//

import Foundation

struct ListingFeed: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let hasMore: Bool
    let items: [Listing]

    enum CodingKeys: String, CodingKey {
        case total, page, limit, items
        case hasMore = "has_more"
    }
}
