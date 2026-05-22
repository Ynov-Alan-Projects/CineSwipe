# CineSwipe — Design Spec

**Date**: 2026-05-22
**Status**: Approved (design phase). Implementation plan pending.
**Platform**: iOS 17+ (SwiftUI, `@Observable`, `ContentUnavailableView`)

## 1. Product Scope

CineSwipe is a French-language iOS movie discovery app powered by The Movie Database (TMDB). Users discover movies through curated category carousels, a Tinder-style swipe feed, save them to Favorites or a Watchlist, and view full details including streaming providers.

### Features (in scope, MVP)

1. **Discover tab** — Category carousels (Trending week, Popular, Top Rated, Upcoming, Action, Drama, Animation). Tap "See all" → full category list.
2. **Swipe tab** — Tinder-style swipe (left=watchlist, right=favorite, up=skip). Existing implementation extended with real feed loader.
3. **Library tab** — Segmented Favorites / Watchlist with swipe-to-delete.
4. **Detail view** — Pushed navigation. Backdrop hero, title/year/rating, synopsis, genres, favorite/watchlist toggles, cast scroll, "Where to watch" (region-aware providers), official trailer embed.
5. **Settings tab** — Clear favorites, clear watchlist, About (version + TMDB attribution).

### Out of scope (V2+)

- Similar movies, technical metadata (budget, runtime details)
- TMDB cloud sync (OAuth v4)
- Multi-language picker (auto-locale only)
- Provider region picker (auto-region only)
- Theme override (system default)
- Search bar
- Offline-first cache

## 2. Architecture

**Pattern**: Lightweight MVVM. SwiftUI + `@Observable` (iOS 17+) for the single shared `MovieViewModel`. Views fetch TMDB endpoints directly via `.task` modifier and hold their own loading state. Persistence is local via `UserDefaults` Codable.

**Reason for choice**: Student-scale MVP, fast iteration, minimum file count. Per-screen ViewModels and repository/store layers were rejected as overkill for this scope.

### Folder layout

```
CineSwipe/
├── App/
│   ├── CineSwipeApp.swift              # entry, injects MovieViewModel
│   └── RootTabView.swift               # 4 tabs
├── Models/
│   ├── Movie.swift                     # existing
│   ├── MovieDetail.swift               # append_to_response payload
│   ├── MovieRef.swift                  # lightweight persisted ref
│   ├── Genre.swift
│   ├── CastMember.swift
│   ├── Video.swift                     # trailer
│   ├── WatchProvider.swift
│   └── PaginatedResponse.swift         # generic
├── Services/
│   ├── TMDBClient.swift                # existing (extend)
│   ├── TMDBConfig.swift                # existing (rotate token, move out of repo)
│   ├── TMDBEndpoints.swift             # path/query builders
│   ├── PersistenceService.swift        # UserDefaults Codable
│   ├── LocaleService.swift             # language + region from Locale.current
│   └── MovieMockService.swift          # existing
├── ViewModels/
│   └── MovieViewModel.swift            # favorites, watchlist, persist
└── Views/
    ├── Discover/
    │   ├── DiscoverView.swift
    │   ├── CategoryCarousel.swift
    │   └── CategoryListView.swift      # "see all"
    ├── Swipe/
    │   └── MovieSwipeView.swift        # existing, add feed loader
    ├── Library/
    │   └── LibraryView.swift           # segmented Favorites/Watchlist
    ├── Detail/
    │   ├── MovieDetailView.swift
    │   ├── CastSection.swift
    │   ├── ProvidersSection.swift
    │   └── TrailerSection.swift
    ├── Settings/
    │   └── SettingsView.swift
    └── Shared/
        ├── GenrePills.swift            # existing
        ├── PosterCard.swift            # reusable
        ├── RatingBadge.swift
        └── LoadingPlaceholder.swift    # skeleton
```

## 3. Data Flow

### App startup

```
CineSwipeApp
  └─ instantiates MovieViewModel()
       └─ PersistenceService.load() → favorites + watchlist from UserDefaults
  └─ injects vm into environment
  └─ renders RootTabView
```

### Discover (tab 1)

`DiscoverView.task` fetches in parallel:

- Trending week
- Popular
- Top Rated
- Upcoming
- Discover by genre 28 (Action)
- Discover by genre 18 (Drama)
- Discover by genre 16 (Animation)

Each section stored in local `@State LoadingState<[Movie]>`. Renders one `CategoryCarousel` per section.

- Tap poster → `NavigationLink` → `MovieDetailView(id:)`
- Tap "See all" → `CategoryListView(source:)` with source descriptor

### Swipe (tab 2)

`MovieSwipeView.task`:

1. Parallel fetch: trending + popular + topRated
2. Dedupe by `id`
3. Filter out ids present in `vm.favorites` or `vm.watchlist`
4. Shuffle
5. Assign as feed

On swipe: `vm.addFavorite(movie)` / `vm.addWatchlist(movie)` (called from existing gesture handler), which persists immediately.

### Library (tab 3)

`LibraryView`:

- Picker (segmented): Favorites | Watchlist
- `List` binding on `vm.favorites` or `vm.watchlist`
- Swipe-to-delete row → `vm.remove(id:)`
- Tap row → `MovieDetailView(id:)`

### Detail (pushed)

`MovieDetailView.task` calls:

```
movie/{id}?append_to_response=credits,videos,watch/providers&language=...&region=...
```

Decoded into `MovieDetail`. Renders sections in order: backdrop hero, title/year/rating, synopsis, genres, action buttons (Favorite/Watchlist toggles), cast horizontal scroll, providers section (region-scoped), trailer (YouTube embed via `WKWebView` in `UIViewRepresentable`).

Action buttons call `vm.toggleFavorite(movie)` / `vm.toggleWatchlist(movie)`.

### Settings (tab 4)

`SettingsView`:

- Button "Clear favorites" → confirmation alert → `vm.clearFavorites()`
- Button "Clear watchlist" → confirmation alert → `vm.clearWatchlist()`
- `NavigationLink` "About" → `AboutView` (version from `Bundle.main`, TMDB attribution text + logo)

## 4. TMDB API

Base URL: `https://api.themoviedb.org/3/`. All requests carry `Authorization: Bearer {token}`, plus query parameters `language={Locale}` and `region={Locale.region}` derived from `LocaleService` (`Locale.current.language.languageCode` + `Locale.current.region`).

| Purpose | Path | Used by | Decodes to |
|---|---|---|---|
| Trending (week) | `/trending/movie/week` | Discover, Swipe | `PaginatedResponse<Movie>` |
| Popular | `/movie/popular` | Discover, Swipe | `PaginatedResponse<Movie>` |
| Top Rated | `/movie/top_rated` | Discover, Swipe | `PaginatedResponse<Movie>` |
| Upcoming | `/movie/upcoming` | Discover | `PaginatedResponse<Movie>` |
| By genre | `/discover/movie?with_genres={id}&sort_by=popularity.desc` | Discover, CategoryList | `PaginatedResponse<Movie>` |
| Detail (enriched) | `/movie/{id}?append_to_response=credits,videos,watch/providers` | Detail | `MovieDetail` |
| Genre list | `/genre/movie/list` | id→name mapping cache | `GenresResponse` |

### New model types

```swift
struct PaginatedResponse<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieDetail: Codable, Identifiable {
    // all Movie fields, plus:
    let runtime: Int?
    let tagline: String?
    let credits: Credits
    let videos: VideosResponse
    let watchProviders: WatchProvidersResponse  // key "watch/providers"
    // CodingKeys maps watchProviders → "watch/providers"
}

struct Credits: Codable { let cast: [CastMember] }

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
}

struct VideosResponse: Codable { let results: [Video] }

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let site: String
    let type: String
    let official: Bool
}

struct WatchProvidersResponse: Codable {
    let results: [String: CountryProviders]   // key = ISO country code
}

struct CountryProviders: Codable {
    let link: String?
    let flatrate: [WatchProvider]?
    let rent: [WatchProvider]?
    let buy: [WatchProvider]?
}

struct WatchProvider: Codable, Identifiable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    var id: Int { providerId }
}
```

### Image URLs

- Poster: `TMDBConfig.imageBase / w342 / {posterPath}` (already implemented on `Movie`)
- Backdrop: `TMDBConfig.imageBase / w780 / {backdropPath}`
- Cast profile: `TMDBConfig.imageBase / w185 / {profilePath}`
- Provider logo: `TMDBConfig.imageBase / w92 / {logoPath}`

### Trailer

Filter `MovieDetail.videos.results` where `site == "YouTube"` && `type == "Trailer"` && `official == true`. Take first match. Embed via:

```
https://www.youtube.com/embed/{video.key}
```

Loaded in `WKWebView` wrapped in `UIViewRepresentable`. No autoplay.

### Providers display

Use `WatchProvidersResponse.results[Locale.current.region]`. Show flatrate first (subscription), then rent, then buy. If no providers for region: show "Not available in your region" message + link to TMDB page if `link` present.

## 5. Persistence

**Store**: `UserDefaults.standard`.

**Persisted type** — `MovieRef`, a lightweight reference (not the full `Movie` payload):

```swift
struct MovieRef: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: Date?
    let voteAverage: Double
    let addedAt: Date
}
```

**Rationale**: ~80 bytes per entry vs ~600 for full `Movie`. Sufficient to render Library rows (poster + title + year + rating). On tap, the full detail is re-fetched.

**Service** (Services/PersistenceService.swift):

```swift
enum PersistenceService {
    static let favoritesKey = "cineswipe.favorites"
    static let watchlistKey = "cineswipe.watchlist"

    static func load(_ key: String) -> [MovieRef] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let refs = try? JSONDecoder().decode([MovieRef].self, from: data)
        else { return [] }
        return refs
    }

    static func save(_ refs: [MovieRef], key: String) {
        guard let data = try? JSONEncoder().encode(refs) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
```

**ViewModel** (ViewModels/MovieViewModel.swift):

```swift
@Observable
final class MovieViewModel {
    private(set) var favorites: [MovieRef] = []
    private(set) var watchlist: [MovieRef] = []

    init() {
        favorites = PersistenceService.load(PersistenceService.favoritesKey)
        watchlist = PersistenceService.load(PersistenceService.watchlistKey)
    }

    func isFavorite(_ id: Int) -> Bool { favorites.contains { $0.id == id } }
    func isInWatchlist(_ id: Int) -> Bool { watchlist.contains { $0.id == id } }

    func toggleFavorite(_ movie: Movie) {
        if isFavorite(movie.id) {
            favorites.removeAll { $0.id == movie.id }
        } else {
            favorites.insert(MovieRef(from: movie), at: 0)
        }
        PersistenceService.save(favorites, key: PersistenceService.favoritesKey)
    }

    func toggleWatchlist(_ movie: Movie) { /* mirror */ }

    enum ListKind { case favorites, watchlist }
    func remove(id: Int, from list: ListKind) { /* swipe-to-delete in Library */ }

    func clearFavorites() { favorites = []; PersistenceService.save([], key: PersistenceService.favoritesKey) }
    func clearWatchlist() { watchlist = []; PersistenceService.save([], key: PersistenceService.watchlistKey) }
}

extension MovieRef {
    init(from movie: Movie) {
        self.init(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            addedAt: Date()
        )
    }
}
```

**Swipe feed dedup**: compute `Set<Int>` from `favorites.map(\.id) + watchlist.map(\.id)`, filter feed pre-shuffle.

## 6. Error Handling & Loading States

### Loading

Each view that fetches owns a local `LoadingState<T>`:

```swift
enum LoadingState<T> {
    case idle, loading, loaded(T), failed(String)
}
```

Skeleton placeholder (`Views/Shared/LoadingPlaceholder.swift`) uses native SwiftUI `.redacted(.placeholder)` modifier.

- **Discover carousels**: skeleton rows during initial load.
- **Detail**: skeleton sections during fetch.
- **Library**: no loading state (data is local, available synchronously).

### Failure

- **Carousel failure**: inline "Couldn't load" + retry button. Other carousels remain functional.
- **Detail failure**: full-screen `ContentUnavailableView` "Movie unavailable" + retry.
- **Swipe feed failure**: full-screen `ContentUnavailableView` + retry.
- **Image failure**: gray rectangle placeholder (already handled by `AsyncImage.failure` branch).

### Fetch pattern

```swift
.task {
    state = .loading
    do {
        let result = try await TMDBClient.shared.trending()
        state = .loaded(result)
    } catch {
        state = .failed(error.localizedDescription)
    }
}
```

`APIError` (already defined in `TMDBConfig.swift`) provides French-localized `errorDescription`.

### Empty states

- **Library empty**: `ContentUnavailableView` "Aucun favori" / "Watchlist vide" + icon + CTA "Découvrir des films". Tab switching implemented via a `Tab` enum (`.discover`, `.swipe`, `.library`, `.settings`) bound to `TabView(selection:)` in `RootTabView`, and a `@Binding<Tab>` is passed down from `RootTabView` into `LibraryView` so the CTA can mutate the selection.
- **Swipe finished**: existing `emptyState` view continues to work.

### Network offline

No explicit offline handling. `URLSession` throws transport error → `APIError.transport` → user sees "Réseau : ...". Acceptable for MVP.

## 7. Testing

**Scope**: targeted unit tests on critical logic. No UI tests, no snapshot tests, no HTTP mocking.

| Target | Type | Cases |
|---|---|---|
| `Movie` decoding | Unit | Decode TMDB JSON sample; all fields correct; `releaseDate` parsed; `softcore` defaults to `false` when absent |
| `MovieDetail` decoding | Unit | `append_to_response` payload decodes; `credits.cast` populated; `videos.results` populated; `watchProviders.results` keyed correctly |
| `PersistenceService` | Unit | Save → load roundtrip; key isolation between favorites/watchlist; decode failure returns `[]` |
| `MovieViewModel` toggles | Unit | `toggleFavorite` adds if absent / removes if present; persistence side effect; `isFavorite` returns correct value |
| `MovieViewModel` swipe filter | Unit | Helper that filters feed excludes ids present in favorites or watchlist |

**Fixtures**: `CineSwipeTests/Fixtures/` containing JSON samples copied from real TMDB responses (one `movie.json`, one `movie_detail.json`).

**Prerequisite**: a `CineSwipeTests` target must exist in the Xcode project. If not present, user adds it via File → New → Target → Unit Testing Bundle.

**Estimated cost**: ~5 test files, ~150 lines, runs in under one second.

## 8. Security & Compliance

- **Bearer token**: currently committed in `TMDBConfig.swift:14`. Must be rotated and moved out of the repository (xcconfig file referenced from `Info.plist`, added to `.gitignore`). Implementation plan must include this step.
- **`.gitignore`**: add `.DS_Store`, `xcuserdata/`, `*.xcconfig` (secrets variant), `DerivedData/`.
- **TMDB attribution**: required by TMDB Terms of Use. About screen must include the text "This product uses the TMDB API but is not endorsed or certified by TMDB" along with the TMDB logo. The logo file (`tmdb-logo.svg` or PNG variants downloaded from TMDB's official assets page) must be bundled into `Assets.xcassets` as an image set named `TMDBLogo`. Implementation plan includes a step to download and add the asset.

## 9. Open Questions

None. All design decisions resolved during brainstorming.

## 10. Implementation Order (Preview)

The implementation plan will sequence work as roughly:

1. Foundation — `RootTabView`, wire `ContentView`, secret management, `.gitignore`.
2. Models — `MovieRef`, `MovieDetail`, supporting types, `PaginatedResponse`.
3. Services — `PersistenceService`, `LocaleService`, `TMDBEndpoints`, extend `TMDBClient` with typed endpoint methods.
4. ViewModel — extend `MovieViewModel` with persistence + toggle methods.
5. Shared views — `PosterCard`, `RatingBadge`, `LoadingPlaceholder`.
6. Discover — `DiscoverView`, `CategoryCarousel`, `CategoryListView`.
7. Detail — `MovieDetailView` + sub-sections.
8. Library — `LibraryView`.
9. Swipe — extend `MovieSwipeView` with real feed loader.
10. Settings — `SettingsView`, `AboutView`.
11. Tests.
12. Polish — empty states, loading skeletons, transitions.

Implementation plan to be authored in a separate document via the `writing-plans` skill.
