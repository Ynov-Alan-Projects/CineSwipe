//
//  TrailerSection.swift
//  CineSwipe
//

import SwiftUI
import WebKit

struct TrailerSection: View {
    let detail: MovieDetail

    var body: some View {
        if let trailer = detail.officialYouTubeTrailer,
           let url = trailer.youtubeEmbedURL {
            VStack(alignment: .leading, spacing: 8) {
                Text("Bande-annonce")
                    .font(.headline)
                    .padding(.horizontal)

                YouTubeWebView(url: url)
                    .aspectRatio(16/9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
            }
        }
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
