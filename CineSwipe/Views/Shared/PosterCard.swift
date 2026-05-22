//
//  PosterCard.swift
//  CineSwipe
//

import SwiftUI

struct PosterCard: View {
    let title: String
    let posterURL: URL?
    let voteAverage: Double
    var width: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: posterURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.15))
                            .overlay(ProgressView())
                    case .failure:
                        Rectangle().fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "film")
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        Color.clear
                    }
                }
                .frame(width: width, height: width * 1.5)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                )

                RatingBadge(voteAverage: voteAverage)
                    .padding(6)
            }
            Text(title)
                .font(.caption.weight(.medium))
                .lineLimit(2)
                .frame(width: width, alignment: .leading)
        }
    }
}

#Preview {
    PosterCard(
        title: "Le Diable s'habille en Prada",
        posterURL: URL(string: "https://image.tmdb.org/t/p/w342/vTIBjWMWx1p5Wv2J3IRhEW13lrj.jpg"),
        voteAverage: 7.4
    )
    .padding()
}
