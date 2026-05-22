//
//  MovieDetailView.swift
//  CineSwipe
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int

    @Environment(MovieViewModel.self) private var vm
    @State private var state: LoadingState<MovieDetail> = .idle

    var body: some View {
        ScrollView {
            switch state {
            case .idle, .loading:
                ProgressView()
                    .padding(.vertical, 80)
            case .loaded(let detail):
                content(detail)
            case .failed(let message):
                ContentUnavailableView {
                    Label("Film indisponible", systemImage: "film.stack")
                } description: {
                    Text(message)
                } actions: {
                    Button("Réessayer") { Task { await load() } }
                }
                .padding(.top, 80)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: movieId) { await load() }
    }

    @ViewBuilder
    private func content(_ detail: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            backdrop(detail)
            titleBlock(detail)
            actionButtons(detail)
            if !detail.overview.isEmpty {
                section(title: "Synopsis") {
                    Text(detail.overview)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            if !detail.genres.isEmpty {
                section(title: "Genres") {
                    HStack {
                        ForEach(detail.genres) { g in
                            Text(g.name)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                }
            }
            CastSection(cast: detail.credits.cast)
            ProvidersSection(detail: detail)
            TrailerSection(detail: detail)
            Spacer(minLength: 32)
        }
    }

    @ViewBuilder
    private func backdrop(_ detail: MovieDetail) -> some View {
        AsyncImage(url: detail.backdropURL()) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFill()
            default:
                Rectangle().fill(Color.gray.opacity(0.2))
            }
        }
        .frame(height: 280)
        .clipped()
        .overlay(
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    @ViewBuilder
    private func titleBlock(_ detail: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(detail.title)
                .font(.title.weight(.bold))
            if let tagline = detail.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                Text(detail.releaseYear)
                if let r = detail.runtime, r > 0 {
                    Text("·")
                    Text("\(r) min")
                }
                Text("·")
                RatingBadge(voteAverage: detail.voteAverage)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func actionButtons(_ detail: MovieDetail) -> some View {
        HStack(spacing: 12) {
            actionButton(
                title: vm.isFavorite(detail.id) ? "Favori" : "Ajouter aux favoris",
                systemImage: vm.isFavorite(detail.id) ? "heart.fill" : "heart",
                tint: .pink
            ) {
                let movie = detail.asMovie()
                vm.toggleFavorite(movie)
            }
            actionButton(
                title: vm.isInWatchlist(detail.id) ? "Dans la liste" : "À voir",
                systemImage: vm.isInWatchlist(detail.id) ? "bookmark.fill" : "bookmark",
                tint: .blue
            ) {
                let movie = detail.asMovie()
                vm.toggleWatchlist(movie)
            }
        }
        .padding(.horizontal)
    }

    private func actionButton(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.18))
                )
                .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(.horizontal)
    }

    private func load() async {
        state = .loading
        do {
            let detail = try await TMDBClient.shared.movieDetail(id: movieId)
            state = .loaded(detail)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

extension MovieDetail {
    /// Bridges MovieDetail back to Movie for use with MovieViewModel toggle methods.
    func asMovie() -> Movie {
        Movie(
            adult: false,
            backdropPath: backdropPath,
            genreIDS: genres.map(\.id),
            id: id,
            title: title,
            originalLanguage: "",
            originalTitle: originalTitle,
            overview: overview,
            popularity: 0,
            posterPath: posterPath,
            releaseDate: releaseDate.map { d in
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                f.locale = Locale(identifier: "en_US_POSIX")
                return f.string(from: d)
            },
            softcore: false,
            video: false,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}
