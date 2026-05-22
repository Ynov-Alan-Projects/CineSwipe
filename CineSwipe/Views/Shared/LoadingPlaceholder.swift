//
//  LoadingPlaceholder.swift
//  CineSwipe
//

import SwiftUI

struct CarouselSkeleton: View {
    var count: Int = 5
    var posterWidth: CGFloat = 130

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<count, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: posterWidth, height: posterWidth * 1.5)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: posterWidth, height: 10)
                    }
                }
            }
            .padding(.horizontal)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    CarouselSkeleton()
}
