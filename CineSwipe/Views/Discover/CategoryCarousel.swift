//
//  CategoryCarousel.swift
//  CineSwipe
//

import SwiftUI

struct CategoryCarousel: View {
    let source: CategorySource
    @State private var state: LoadingState<[Movie]> = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(source.title)
                    .font(.title3.weight(.semibold))
                Spacer()
                NavigationLink(value: source) {
                    Text("Voir tout")
                        .font(.subheadline)
                }
                .opacity(isLoaded ? 1 : 0)
            }
            .padding(.horizontal)

            content
        }
        .task {
            await load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle, .loading:
            CarouselSkeleton()
        case .loaded(let movies):
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(movies.prefix(20)) { movie in
                        NavigationLink(value: movie.id) {
                            PosterCard(
                                title: movie.title,
                                posterURL: movie.posterURL(.w342),
                                voteAverage: movie.voteAverage
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        case .failed(let message):
            HStack {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Réessayer") {
                    Task { await load() }
                }
                .font(.footnote)
            }
            .padding(.horizontal)
        }
    }

    private var isLoaded: Bool {
        if case .loaded = state { return true }
        return false
    }

    private func load() async {
        state = .loading
        do {
            let movies = try await source.fetch()
            state = .loaded(movies)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
