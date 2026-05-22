//
//  RootTabView.swift
//  CineSwipe
//

import SwiftUI

enum Tab: Hashable {
    case discover, swipe, library, settings
}

struct RootTabView: View {
    @State private var selection: Tab = .discover

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack {
                DiscoverView()
            }
            .tabItem { Label("Découvrir", systemImage: "sparkles") }
            .tag(Tab.discover)

            NavigationStack {
                SwipeFeedView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Int.self) { id in
                        MovieDetailView(movieId: id)
                    }
            }
            .tabItem { Label("Swipe", systemImage: "rectangle.stack") }
            .tag(Tab.swipe)

            NavigationStack {
                Text("Bibliothèque")        // placeholder, replaced in Phase 7
                    .navigationTitle("Bibliothèque")
            }
            .tabItem { Label("Bibliothèque", systemImage: "heart.text.square") }
            .tag(Tab.library)

            NavigationStack {
                Text("Réglages")            // placeholder, replaced in Phase 9
                    .navigationTitle("Réglages")
            }
            .tabItem { Label("Réglages", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
    }
}

#Preview {
    RootTabView()
        .environment(MovieViewModel())
}
