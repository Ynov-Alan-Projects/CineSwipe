//
//  MovieDetailView.swift
//  CineSwipe
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    var body: some View {
        Text("Detail \(movieId)")
            .navigationTitle("Détail")
    }
}
