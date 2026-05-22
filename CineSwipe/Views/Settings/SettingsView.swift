//
//  SettingsView.swift
//  CineSwipe
//

import SwiftUI

struct SettingsView: View {
    @Environment(MovieViewModel.self) private var vm
    @State private var confirm: ConfirmKind? = nil

    enum ConfirmKind: Identifiable {
        case favorites, watchlist
        var id: Int { hashValue }
    }

    var body: some View {
        List {
            Section("Données") {
                Button(role: .destructive) {
                    confirm = .favorites
                } label: {
                    Label("Vider les favoris (\(vm.favorites.count))", systemImage: "heart.slash")
                }
                Button(role: .destructive) {
                    confirm = .watchlist
                } label: {
                    Label("Vider la watchlist (\(vm.watchlist.count))", systemImage: "bookmark.slash")
                }
            }

            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    Label("À propos", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Réglages")
        .alert(item: $confirm) { kind in
            switch kind {
            case .favorites:
                return Alert(
                    title: Text("Vider les favoris ?"),
                    message: Text("Cette action est définitive."),
                    primaryButton: .destructive(Text("Vider")) { vm.clearFavorites() },
                    secondaryButton: .cancel()
                )
            case .watchlist:
                return Alert(
                    title: Text("Vider la watchlist ?"),
                    message: Text("Cette action est définitive."),
                    primaryButton: .destructive(Text("Vider")) { vm.clearWatchlist() },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
