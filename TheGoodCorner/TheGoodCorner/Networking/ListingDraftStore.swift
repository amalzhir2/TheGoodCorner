//
//  ListingDraftStore.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 20/09/2026.
//

import Foundation

protocol ListingDraftStoring {
    func load() -> ListingDraft?
    func save(_ draft: ListingDraft)
    func clear()
}

final class ListingDraftStore: ListingDraftStoring {
    private let key = "listingDraft"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> ListingDraft? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ListingDraft.self, from: data)
    }

    func save(_ draft: ListingDraft) {
        guard let data = try? JSONEncoder().encode(draft) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }
}
