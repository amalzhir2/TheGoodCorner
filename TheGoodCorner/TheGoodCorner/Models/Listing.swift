//
//  Listing.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 17/09/2026.
//
import  Foundation

struct Listing: Decodable, Identifiable {
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
    
    func thumbnailURL(baseURL: URL) -> URL? {
        guard let path = imagesUrl?.thumb ?? imagesUrl?.small else { return nil }
        return URL(string: path, relativeTo: baseURL)
    }
    
    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var formattedPrice: String {
        Self.priceFormatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    var formattedDate: String {
        creationDate.formattedDate
    }
    
    var accessibilityFormattedDate: String {
        creationDate.accessibilityFormattedDate
    }
}
