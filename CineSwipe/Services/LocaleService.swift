//
//  LocaleService.swift
//  CineSwipe
//

import Foundation

nonisolated enum LocaleService {
    /// TMDB-compatible language tag, e.g. "fr-FR", "en-US". Falls back to "en-US".
    static var language: String {
        let lang = Locale.current.language.languageCode?.identifier ?? "en"
        let region = Locale.current.region?.identifier ?? "US"
        return "\(lang)-\(region)"
    }

    /// ISO 3166-1 alpha-2 region code, e.g. "FR". Falls back to "US".
    static var region: String {
        Locale.current.region?.identifier ?? "US"
    }
}
