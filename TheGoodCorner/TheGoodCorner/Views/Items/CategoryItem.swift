//
//  CategoryChip.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 18/09/2026.
//

import SwiftUI

struct CategoryItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isSelected ? "Touchez pour désélectionner cette catégorie" : "Touchez pour filtrer par cette catégorie")
    }
}

#Preview {
    HStack {
        CategoryItem(title: "Sélectionnés", isSelected: true) {}
        CategoryItem(title: "Non sélectionnés", isSelected: false) {}
    }
    .padding()
}
