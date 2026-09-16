//
//  Listing.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 17/09/2026.
//
import  Foundation

struct Listing: Decodable {
    let id: Int
    let categoryId: Int
    let title: String
    let description: String
    let price: Double
    let creationDate: Date
    let isUrgent: Bool
    let imagesUrl: ImagesURL?

    struct ImagesURL: Decodable, Equatable {
        let small: String?
        let thumb: String?
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, price
        case categoryId = "category_id"
        case creationDate = "creation_date"
        case isUrgent = "is_urgent"
        case imagesUrl = "images_url"
    }
}

