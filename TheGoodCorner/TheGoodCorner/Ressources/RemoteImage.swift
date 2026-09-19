//
//  RemoteImage.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 19/09/2026.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholder
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .background(Color(.secondarySystemBackground))
        // Image décorative : masquée pour VoiceOver
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .imageScale(.large)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
