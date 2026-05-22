//
//  CineSwipeApp.swift
//  CineSwipe
//

import SwiftUI

@main
struct CineSwipeApp: App {
    @State private var movieViewModel = MovieViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(movieViewModel)
        }
    }
}
