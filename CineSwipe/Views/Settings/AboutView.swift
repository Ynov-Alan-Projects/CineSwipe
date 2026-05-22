//
//  AboutView.swift
//  CineSwipe
//

import SwiftUI

struct AboutView: View {
    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(v) (\(b))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "popcorn.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                    .padding(.top, 24)

                Text("CineSwipe")
                    .font(.title.weight(.bold))
                Text(versionString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider().padding(.horizontal)

                VStack(spacing: 12) {
                    Image("TMDBLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)

                    Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    Link("Visiter themoviedb.org", destination: URL(string: "https://www.themoviedb.org")!)
                        .font(.footnote)
                }

                Spacer()
            }
        }
        .navigationTitle("À propos")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
