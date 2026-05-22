//
//  DiscoverView.swift
//  CineSwipe
//

import SwiftUI

struct DiscoverView: View {
    private let sources: [CategorySource] = [
        .trendingWeek,
        .popular,
        .topRated,
        .upcoming,
        .genre(id: 28, name: "Action"),
        .genre(id: 18, name: "Drame"),
        .genre(id: 16, name: "Animation")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sources) { source in
                    CategoryCarousel(source: source)
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Découvrir")
        .navigationDestination(for: CategorySource.self) { source in
            CategoryListView(source: source)
        }
        .navigationDestination(for: Int.self) { movieId in
            MovieDetailView(movieId: movieId)
        }
    }
}
