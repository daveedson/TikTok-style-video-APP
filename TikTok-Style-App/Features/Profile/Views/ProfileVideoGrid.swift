//
//  ProfileVideoGrid.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ProfileVideoGrid: View {
    let videos: [Video]
    var onVideoTap: (Video) -> Void = { _ in }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(videos) { video in
                VideoThumbnailCell(video: video)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onVideoTap(video)
                    }
            }
        }
    }
}


struct VideoThumbnailCell: View {
    let video: Video

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if let thumbnailURL = video.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderGradient
                        case .empty:
                            placeholderGradient
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        @unknown default:
                            placeholderGradient
                        }
                    }
                } else {
                    placeholderGradient
                }

               
                HStack(spacing: 4) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))

                    Text(video.likeCount.formattedCompact)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.5))
                .cornerRadius(4)
                .padding(6)
            }
            .frame(width: geometry.size.width, height: geometry.size.width * 1.3)
            .clipped()
        }
        .aspectRatio(0.77, contentMode: .fit)
    }

    private var placeholderGradient: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: randomGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var randomGradientColors: [Color] {
        let colorSets: [[Color]] = [
            [.purple.opacity(0.7), .pink.opacity(0.5)],
            [.orange.opacity(0.7), .yellow.opacity(0.5)],
            [.blue.opacity(0.7), .cyan.opacity(0.5)],
            [.pink.opacity(0.7), .red.opacity(0.5)],
            [.green.opacity(0.7), .mint.opacity(0.5)],
            [.indigo.opacity(0.7), .purple.opacity(0.5)]
        ]
        return colorSets[video.id % colorSets.count]
    }
}

#Preview {
    ScrollView {
        ProfileVideoGrid(videos: [])
    }
    .background(Color.backgroundLight)
}
