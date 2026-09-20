//
//  ListingDraft.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 20/09/2026.
//

import Foundation

struct ListingDraft: Codable, Equatable {
    var title: String = ""
    var description: String = ""
    var price: String = ""
    var categoryId: Int?
    var imageData: Data?
    var isUrgent: Bool = false

    var isEmpty: Bool {
        title.isEmpty && description.isEmpty && price.isEmpty && categoryId == nil && imageData == nil && !isUrgent
    }
}
