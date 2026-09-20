//
//  ListingDraftFormView.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 20/09/2026.
//

import SwiftUI
import PhotosUI

struct ListingDraftFormView: View {
    @ObservedObject var viewModel: ListingDraftViewModel
    let categories: [Category]

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                imageSection
                categorySection
                detailsSection
            }
            .navigationTitle("Mon brouillon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Supprimer", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(viewModel.draft.isEmpty)
                }
            }
            .alert(
                "Supprimer le brouillon ?",
                isPresented: $showDeleteConfirmation
            ) {
                Button("Supprimer", role: .destructive) {
                    viewModel.reset()
                    dismiss()
                }
                Button("Annuler", role: .cancel) {}
            }
            .onChange(of: selectedPhoto) {newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.draft.imageData = data
                    }
                }
            }
        }
    }
    
    private var imageSection: some View {
        Section("Image") {
            if let imageData = viewModel.draft.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .clipped()
                    .accessibilityHidden(true)
            }
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label(
                    viewModel.draft.imageData == nil ? "Ajouter une image" : "Changer l'image",
                    systemImage: "photo.on.rectangle"
                )
            }
            if viewModel.draft.imageData != nil {
                Button("Retirer l'image", role: .destructive) {
                    viewModel.draft.imageData = nil
                    selectedPhoto = nil
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Détails") {
            TextField("Titre", text: $viewModel.draft.title)
            TextField("Prix (€)", text: $viewModel.draft.price)
                .keyboardType(.decimalPad)
            TextField("Description", text: $viewModel.draft.description, axis: .vertical)
                .lineLimit(3...6)
            Toggle("Annonce urgente", isOn: $viewModel.draft.isUrgent)
        }
    }
    
    private var categorySection: some View {
        Section("Catégorie") {
            if categories.isEmpty {
                Text("Aucune catégorie disponible")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Catégorie", selection: $viewModel.draft.categoryId) {
                    Text("Aucune").tag(Int?.none)
                    ForEach(categories) { category in
                        Text(category.name).tag(Int?.some(category.id))
                    }
                }
            }
        }
    }
}

#Preview {
    ListingDraftFormView(
        viewModel: ListingDraftViewModel(),
        categories: [Category(id: 1, name: "Véhicules")]
    )
}
