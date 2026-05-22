//
//  CategoryListView.swift
//  CineSwipe
//

import SwiftUI

struct CategoryListView: View {
    let source: CategorySource

    @State private var state: LoadingState<[Movie]> = .idle

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .padding(.vertical, 60)
            case .loaded(let movies):
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie.id) {
                            PosterCard(
                                title: movie.title,
                                posterURL: movie.posterURL(.w342),
                                voteAverage: movie.voteAverage,
                                width: 110
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            case .failed(let message):
                ContentUnavailableView {
                    Label("Impossible de charger", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Réessayer") {
                        Task { await load() }
                    }
                }
                .padding(.top, 60)
            }
        }
        .navigationTitle(source.title)
        .navigationBarTitleDisplayMode(.large)
        .task { await load() }
    }

    private func load() async {
        state = .loading
        do {
            async let p1 = source.fetch(page: 1)
            async let p2 = source.fetch(page: 2)
            async let p3 = source.fetch(page: 3)
            let combined = try await (p1 + p2 + p3)
            var seen = Set<Int>()
            let deduped = combined.filter { seen.insert($0.id).inserted }
            state = .loaded(deduped)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
