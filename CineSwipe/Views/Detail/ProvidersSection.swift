//
//  ProvidersSection.swift
//  CineSwipe
//

import SwiftUI

struct ProvidersSection: View {
    let detail: MovieDetail

    var body: some View {
        let region = LocaleService.region
        let providers = detail.providers(forRegion: region)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Où regarder")
                    .font(.headline)
                Spacer()
                if let urlString = providers?.link, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Text("Voir sur TMDB")
                            .font(.subheadline)
                    }
                }
            }

            if let providers {
                providerGroup(title: "Streaming", items: providers.flatrate)
                providerGroup(title: "Location", items: providers.rent)
                providerGroup(title: "Achat", items: providers.buy)
                if isEmpty(providers) {
                    unavailable
                }
            } else {
                unavailable
            }
        }
        .padding(.horizontal)
    }

    private var unavailable: some View {
        Text("Non disponible dans votre région.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private func isEmpty(_ providers: CountryProviders) -> Bool {
        (providers.flatrate?.isEmpty ?? true)
            && (providers.rent?.isEmpty ?? true)
            && (providers.buy?.isEmpty ?? true)
    }

    @ViewBuilder
    private func providerGroup(title: String, items: [WatchProvider]?) -> some View {
        if let items, !items.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(items) { p in
                            providerCell(p)
                        }
                    }
                }
            }
        }
    }

    private func providerCell(_ provider: WatchProvider) -> some View {
        VStack(spacing: 4) {
            AsyncImage(url: provider.logoURL()) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFit()
                default:
                    RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(provider.providerName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}
