//
//  RatingBadge.swift
//  CineSwipe
//

import SwiftUI

struct RatingBadge: View {
    let voteAverage: Double

    private var formatted: String {
        String(format: "%.1f", voteAverage)
    }

    private var color: Color {
        switch voteAverage {
        case 7.5...: return .green
        case 5.5..<7.5: return .yellow
        default: return .red
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(formatted)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.ultraThinMaterial))
    }
}

#Preview {
    HStack {
        RatingBadge(voteAverage: 8.4)
        RatingBadge(voteAverage: 6.2)
        RatingBadge(voteAverage: 4.1)
    }
    .padding()
}
