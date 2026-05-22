//
//  GenrePills.swift
//  CineSwipe
//

import SwiftUI

struct GenrePills: View {
    let genres: [Int]

    private static let genreNames: [Int: String] = [
        28: "Action",
        12: "Aventure",
        16: "Animation",
        35: "Comédie",
        80: "Crime",
        99: "Documentaire",
        18: "Drame",
        10751: "Famille",
        14: "Fantastique",
        36: "Histoire",
        27: "Horreur",
        10402: "Musique",
        9648: "Mystère",
        10749: "Romance",
        878: "Science-Fiction",
        10770: "Téléfilm",
        53: "Thriller",
        10752: "Guerre",
        37: "Western"
    ]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(genres.prefix(3), id: \.self) { id in
                if let name = Self.genreNames[id] {
                    Text(name)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.ultraThinMaterial))
                }
            }
        }
    }
}
