//
//  MoviePostersBackground.swift
//  CineSwipe


import SwiftUI

// MARK: - Fond animé : affiches qui montent

struct MoviePostersBackground: View {

    private let columns: [[URL]]

    init(sampleURLs: [URL]) {
        // Mélange une seule fois, puis répartit en 3 colonnes sans recoupement
        let shuffled = sampleURLs.shuffled()
        self.columns = Self.split(shuffled, into: 3)
    }

    var body: some View {
        GeometryReader { geo in
            let posterW = geo.size.width / 3.3

            HStack(alignment: .top, spacing: 8) {
                PosterColumn(urls: columns[0],
                             posterWidth: posterW,
                             speed: 28,
                             phaseOffset: 0)

                PosterColumn(urls: columns[1],
                             posterWidth: posterW,
                             speed: 44,
                             phaseOffset: 0.4)
                    .padding(.top, posterW * 0.5)

                PosterColumn(urls: columns[2],
                             posterWidth: posterW,
                             speed: 34,
                             phaseOffset: 0.2)
                    .padding(.top, posterW * 0.25)
            }
            .frame(width: geo.size.width, height: geo.size.height,
                   alignment: .top)
            .rotation3DEffect(.degrees(8), axis: (x: 0, y: 0, z: 0))
        }
    }

    /// Découpe `array` en `parts` sous-tableaux disjoints, équilibrés
    /// (les premières parts reçoivent un élément en plus si le reste n'est pas nul).
    private static func split<T>(_ array: [T], into parts: Int) -> [[T]] {
        guard parts > 0 else { return [] }
        let n = array.count
        let base = n / parts
        let remainder = n % parts

        var result: [[T]] = []
        var index = 0
        for i in 0..<parts {
            let size = base + (i < remainder ? 1 : 0)
            let slice = Array(array[index..<(index + size)])
            result.append(slice)
            index += size
        }
        return result
    }
}

// MARK: - Une colonne d'affiches qui boucle vers le haut

private struct PosterColumn: View {
    let urls: [URL]
    let posterWidth: CGFloat
    let speed: Double          // points / seconde
    let phaseOffset: Double    // décalage temporel 0…1 pour désynchroniser

    var body: some View {
        let posterHeight = posterWidth * 1.5
        let spacing: CGFloat = 8
        let itemH = posterHeight + spacing
        let total = itemH * CGFloat(urls.count)   // hauteur d'un cycle

        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate + phaseOffset * Double(total) / speed
            // défilement vers le haut : offset négatif qui revient à 0 toutes les `total / speed` secondes
            let progress = (t * speed).truncatingRemainder(dividingBy: Double(total))
            let yOffset = -CGFloat(progress)

            VStack(spacing: spacing) {
                // 2 copies à la suite -> boucle invisible
                ForEach(0..<2, id: \.self) { copy in
                    ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .empty:
                                Color.white.opacity(0.05)
                            case .failure:
                                Color.white.opacity(0.05)
                            @unknown default:
                                Color.clear
                            }
                        }
                        .frame(width: posterWidth, height: posterHeight)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    }
                }
            }
            .offset(y: yOffset)
        }
        .frame(width: posterWidth, alignment: .top)
    }
}

#Preview {
    MoviePostersBackground(sampleURLs: [
        "https://image.tmdb.org/t/p/w342/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg", // Avengers
        "https://image.tmdb.org/t/p/w342/q719jXXEzOoYaps6babgKnONONX.jpg",
        "https://image.tmdb.org/t/p/w342/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg",
        "https://image.tmdb.org/t/p/w342/9PFonBhy4cQy7Jz20NpMygczOkv.jpg",
        "https://image.tmdb.org/t/p/w342/d5NXSklXo0qyIYkgV94XAgMIckC.jpg",
        "https://image.tmdb.org/t/p/w342/kyeqWdyUXW608qlYkRqosgbbJyK.jpg",
        "https://image.tmdb.org/t/p/w342/A31kbATTwXqipv9bzdg13j16NSY.jpg",
        "https://image.tmdb.org/t/p/w342/jBJWaqoSCiARWtfV0GlqHrcdidd.jpg",
        "https://image.tmdb.org/t/p/w342/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg",
        "https://image.tmdb.org/t/p/w342/kyeqWdyUXW608qlYkRqosgbbJyK.jpg",
        "https://image.tmdb.org/t/p/w342/A31kbATTwXqipv9bzdg13j16NSY.jpg",
        "https://image.tmdb.org/t/p/w342/jBJWaqoSCiARWtfV0GlqHrcdidd.jpg",
        "https://image.tmdb.org/t/p/w342/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg",
    ].compactMap(URL.init(string:))
    )
}
