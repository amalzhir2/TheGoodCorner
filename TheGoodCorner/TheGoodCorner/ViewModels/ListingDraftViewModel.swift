//
//  ListingDraftViewModel.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 20/09/2026.
//

import Foundation
import Combine

@MainActor
final class ListingDraftViewModel: ObservableObject {
    @Published var draft: ListingDraft
    @Published private(set) var hasSavedDraft: Bool

    private let store: ListingDraftStoring
    private var cancellable: AnyCancellable?

    init(store: ListingDraftStoring? = nil) {
        self.store = store ?? ListingDraftStore()
        let restored = store?.load()
        self.draft = restored ?? ListingDraft()
        self.hasSavedDraft = restored != nil

        // Sauvegarde automatique à chaque modification pour restaurer
        // la dernière version en cours de développement au relancement.
        cancellable = $draft
            .dropFirst()
            .sink { [weak self] newValue in
                self?.persist(newValue)
            }
    }

    private func persist(_ draft: ListingDraft) {
        if draft.isEmpty {
            store.clear()
            hasSavedDraft = false
        } else {
            store.save(draft)
            hasSavedDraft = true
        }
    }

    /// Supprime totalement le brouillon (nouvelle annonce vierge).
    func reset() {
        store.clear()
        hasSavedDraft = false
        draft = ListingDraft()
    }
}
