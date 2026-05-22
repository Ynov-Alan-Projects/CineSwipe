//
//  CastSection.swift
//  CineSwipe
//

import SwiftUI

struct CastSection: View {
    let cast: [CastMember]

    var body: some View {
        let visible = Array(cast.sorted(by: { $0.order < $1.order }).prefix(15))
        if visible.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Distribution")
                    .font(.headline)
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(visible) { member in
                            castCell(member)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func castCell(_ member: CastMember) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: member.profileURL()) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.15))
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.15))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    Color.clear
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(member.name)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            Text(member.character)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(width: 90)
    }
}
