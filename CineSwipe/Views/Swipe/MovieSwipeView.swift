//
//  MovieSwipeView.swift
//  CineSwipe



import SwiftUI

// MARK: - Direction du swipe
enum SwipeDirectionView {
    case left      // Watchlist (à voir)
    case right     // Favoris
    case up        // Skip / suivant sans action
}

// MARK: - Vue principale
struct MovieSwipeView: View {

    @Environment(MovieViewModel.self) var vm

    /// Films à parcourir (peut venir d'une recherche, du trending, etc.)
    let movies: [Movie]

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {

            // MARK: Background ambiance
            backgroundGradient

            VStack(spacing: 0) {

                header

                Spacer()

                // MARK: Pile de cartes
                ZStack {
                    if currentIndex >= movies.count {
                        emptyState
                    } else {
                        // Affiche les 3 prochaines cartes empilées
                        ForEach(visibleIndices, id: \.self) { index in
                            let isTop = index == currentIndex
                            let depth = index - currentIndex

                            MovieCard(movie: movies[index], dragOffset: isTop ? dragOffset : .zero)
                                .scaleEffect(isTop ? 1 : (1 - CGFloat(depth) * 0.05))
                                .offset(y: isTop ? 0 : CGFloat(depth) * 12)
                                .offset(isTop ? dragOffset : .zero)
                                .rotationEffect(
                                    .degrees(isTop ? Double(dragOffset.width / 18) : 0)
                                )
                                .opacity(isTop ? 1 : (1 - Double(depth) * 0.15))
                                .zIndex(Double(movies.count - index))
                                .gesture(isTop ? dragGesture : nil)
                                .animation(.spring(response: 0.45, dampingFraction: 0.75), value: currentIndex)
                                .overlay(alignment: .top) {
                                    if isTop {
                                        decisionBadges
                                            .padding(.top, 24)
                                    }
                                }
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                Spacer()

                // MARK: Boutons d'action manuels
                actionButtons
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sous-vues

    private var backgroundGradient: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Halo coloré selon le swipe en cours
            RadialGradient(
                colors: [
                    haloColor.opacity(0.35),
                    haloColor.opacity(0.0)
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .blur(radius: 40)
            .animation(.easeOut(duration: 0.2), value: dragOffset)
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack {
            
                
                Text("\(remainingCount) films à explorer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "popcorn.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            Text("Plus aucun film à découvrir")
                .font(.headline)
            Text("Reviens plus tard pour de nouvelles suggestions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                withAnimation { currentIndex = 0 }
            } label: {
                Label("Recommencer", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(.ultraThinMaterial))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding()
    }

    // Badges "Favori" / "À voir" / "Skip" qui apparaissent pendant le drag
    private var decisionBadges: some View {
        HStack {
            // Watchlist (gauche)
            badge(text: "À VOIR", color: .blue, icon: "bookmark.fill", rotation: -15)
                .opacity(Double(-dragOffset.width / 120).clamped(to: 0...1))

            Spacer()

            // Favoris (droite)
            badge(text: "FAVORI", color: .pink, icon: "heart.fill", rotation: 15)
                .opacity(Double(dragOffset.width / 120).clamped(to: 0...1))
        }
        .overlay(
            // Skip (haut)
            badge(text: "SKIP", color: .gray, icon: "arrow.up", rotation: 0)
                .opacity(Double(-dragOffset.height / 140).clamped(to: 0...1))
                .offset(y: 40)
        )
        .padding(.horizontal, 12)
        .allowsHitTesting(false)
    }

    private func badge(text: String, color: Color, icon: String, rotation: Double) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.title3.weight(.heavy))
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(color, lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .rotationEffect(.degrees(rotation))
    }

    private var actionButtons: some View {
        HStack(spacing: 28) {

            // Skip
            circleButton(icon: "xmark", color: .gray, size: 56) {
                triggerSwipe(.up)
            }

            // Watchlist
            circleButton(icon: "bookmark.fill", color: .blue, size: 68) {
                triggerSwipe(.left)
            }

            // Favori
            circleButton(icon: "heart.fill", color: .pink, size: 68) {
                triggerSwipe(.right)
            }
        }
        .disabled(currentIndex >= movies.count)
        .opacity(currentIndex >= movies.count ? 0.4 : 1)
    }

    private func circleButton(icon: String, color: Color, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle().strokeBorder(color.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: color.opacity(0.25), radius: 12, y: 6)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Logique de swipe

    private var visibleIndices: [Int] {
        let end = min(currentIndex + 3, movies.count)
        return Array(currentIndex..<end).reversed()
    }

    private var remainingCount: Int {
        max(movies.count - currentIndex, 0)
    }

    private var haloColor: Color {
        if dragOffset.width > 20 { return .pink }
        if dragOffset.width < -20 { return .blue }
        if dragOffset.height < -20 { return .gray }
        return .clear
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                let threshold: CGFloat = 110

                if horizontal > threshold {
                    triggerSwipe(.right)
                } else if horizontal < -threshold {
                    triggerSwipe(.left)
                } else if vertical < -threshold {
                    triggerSwipe(.up)
                } else {
                    // Retour à la position d'origine
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    private func triggerSwipe(_ direction: SwipeDirectionView) {
        guard currentIndex < movies.count else { return }
        let movie = movies[currentIndex]

        // Animation de sortie
        withAnimation(.easeOut(duration: 0.25)) {
            switch direction {
            case .right:
                dragOffset = CGSize(width: 600, height: 40)
            case .left:
                dragOffset = CGSize(width: -600, height: 40)
            case .up:
                dragOffset = CGSize(width: 0, height: -800)
            }
        }

        // Haptique
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()

        // Action métier
        Task {
            do {
                switch direction {
                case .right:
                    try await vm.addMovieToFavorite(movie)
                    await vm.refreshFavorites()
                case .left:
                    try await vm.addMovieToWatchlist(movie)
                    await vm.refreshWatchlist()
                case .up:
                    break
                }
            } catch {
                print("Erreur swipe:", error)
            }
        }

        // Passe à la carte suivante après l'animation
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            currentIndex += 1
            dragOffset = .zero
        }
    }
}

// MARK: - Carte de film
private struct MovieCard: View {
    let movie: Movie
    let dragOffset: CGSize

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {

                // Image plein cadre
                AsyncImage(url: movie.posterURL(.w500)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()

                // Dégradé du bas pour la lisibilité du texte
                LinearGradient(
                    colors: [
                        .black.opacity(0.0),
                        .black.opacity(0.55),
                        .black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geo.size.height * 0.55)
                .frame(maxHeight: .infinity, alignment: .bottom)

                // Bloc d'info
                VStack(alignment: .leading, spacing: 8) {

                    Text(movie.title)
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Label(movie.releaseYear, systemImage: "calendar")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.ultraThinMaterial))

                        // Aperçu genres : on garde le composant existant
                        GenrePills(genres: movie.genreIDS)
                    }
                    .foregroundStyle(.white)

                    Text(movie.overview)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(3)
                        .padding(.top, 4)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

// MARK: - Style de bouton pressable
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Helper
private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview("Swipe") {
    NavigationStack {
        MovieSwipeView(movies: MovieMockService.shared.movies)
            .environment(MovieViewModel())
    }
}

// MARK: - Feed-loading wrapper

struct SwipeFeedView: View {
    @Environment(MovieViewModel.self) private var vm
    @State private var state: LoadingState<[Movie]> = .idle

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .task { await load() }
        case .loaded(let movies):
            if movies.isEmpty {
                ContentUnavailableView {
                    Label("Plus rien à découvrir", systemImage: "popcorn")
                } description: {
                    Text("Tu as déjà sauvegardé tous les films suggérés. Reviens plus tard.")
                } actions: {
                    Button("Recharger") { Task { await load() } }
                }
            } else {
                MovieSwipeView(movies: movies)
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Pas de films", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Réessayer") { Task { await load() } }
            }
        }
    }

    private func load() async {
        state = .loading
        do {
            async let trending = TMDBClient.shared.trendingWeek().results
            async let popular  = TMDBClient.shared.popular().results
            async let topRated = TMDBClient.shared.topRated().results

            let combined = try await trending + popular + topRated

            // Dedupe by id
            var seen = Set<Int>()
            var unique = combined.filter { seen.insert($0.id).inserted }

            // Exclude already-saved
            let saved = vm.savedIDs
            unique.removeAll { saved.contains($0.id) }

            // Shuffle for variety
            unique.shuffle()

            state = .loaded(unique)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
