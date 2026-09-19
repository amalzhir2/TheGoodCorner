//
//  Date.swift
//  TheGoodCorner
//
//  Created by amal zouhair on 19/09/2026.
//

import Foundation

extension Date {
    
    private static let formattersCache: [DateFormatter.Style: DateFormatter] = {
        var cache = [DateFormatter.Style: DateFormatter]()
        let styles: [DateFormatter.Style] = [.short, .medium, .long, .full]
        
        for style in styles {
            let formatter = DateFormatter()
            formatter.dateStyle = style
            formatter.timeStyle = .none
            cache[style] = formatter
        }
        return cache
    }()
    
    /// Formate la date selon le style demandé
    /// - Parameter style: le style de formatage (.medium pour l'affichage, .long pour l'accessibilité)
    /// - Returns: la date formatée sous forme de chaîne
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = Self.formattersCache[style] ?? Self.formattersCache[.medium]!
        return formatter.string(from: self)
    }
    
    /// Version compacte pour l'affichage visuel (ex : "19 sept. 2026")
    var formattedDate: String {
        formatted(style: .medium)
    }
    
    /// Version complète pour VoiceOver, mois en toutes lettres (ex : "19 septembre 2026")
    var accessibilityFormattedDate: String {
        formatted(style: .long)
    }
}
