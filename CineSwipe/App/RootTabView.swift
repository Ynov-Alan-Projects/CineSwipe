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
                LibraryView(selectedTab: $selection)
            }
            .tabItem { Label("Bibliothèque", systemImage: "heart.text.square") }
            .tag(Tab.library)

            NavigationStack {
                SettingsView()
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
