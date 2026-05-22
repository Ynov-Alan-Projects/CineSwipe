//
//  LibraryView.swift
//  CineSwipe
//

import SwiftUI

struct LibraryView: View {
    @Environment(MovieViewModel.self) private var vm
    @Binding var selectedTab: Tab
    @State private var section: Section = .favorites

    enum Section: String, CaseIterable, Identifiable {
        case favorites = "Favoris"
        case watchlist = "À voir"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Section", selection: $section) {
                ForEach(Section.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            content
        }
        .navigationTitle("Bibliothèque")
        .navigationDestination(for: Int.self) { id in
            MovieDetailView(movieId: id)
        }
    }

    @ViewBuilder
    private var content: some View {
        let items = section == .favorites ? vm.favorites : vm.watchlist
        if items.isEmpty {
            emptyState
        } else {
            List {
                ForEach(items) { ref in
                    NavigationLink(value: ref.id) {
                        LibraryRow(ref: ref)
                    }
                }
                .onDelete { indexSet in
                    let kind: MovieViewModel.ListKind = section == .favorites ? .favorites : .watchlist
                    indexSet.map { items[$0].id }.forEach { vm.remove(id: $0, from: kind) }
                }
            }
            .listStyle(.plain)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                section == .favorites ? "Aucun favori" : "Watchlist vide",
                systemImage: section == .favorites ? "heart" : "bookmark"
            )
        } description: {
            Text(
                section == .favorites
                    ? "Ajoute des films depuis Découvrir ou Swipe."
                    : "Marque des films à regarder plus tard."
            )
        } actions: {
            Button("Découvrir des films") {
                selectedTab = .discover
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity)
    }
}

private struct LibraryRow: View {
    let ref: MovieRef

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: ref.posterURL(.w185)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Rectangle().fill(Color.gray.opacity(0.15))
                }
            }
            .frame(width: 56, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(ref.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text(ref.releaseYear)
                    RatingBadge(voteAverage: ref.voteAverage)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
