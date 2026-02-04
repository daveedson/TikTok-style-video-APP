//
//  VideoFeedCell.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI
import AVKit

struct VideoFeedCell: View {
    @Binding var video: Video
    let isVisible: Bool
    var onUsernameTap: () -> Void = {}

    @StateObject private var likesStore = LikesStore.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
               
                Color.backgroundDark

                // Video Player
                VideoPlayerView(
                    videoId: video.id,
                    videoURL: video.videoURL,
                    thumbnailURL: video.thumbnailURL,
                    isVisible: isVisible
                )

                VStack {
                    Spacer()
                    LinearGradient.videoOverlayGradient
                        .frame(height: geometry.size.height * 0.4)
                }
                VStack {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 12) {
                        VideoOverlayView(
                            video: video,
                            onUsernameTap: onUsernameTap
                        )
                        .frame(maxWidth: geometry.size.width * 0.7, alignment: .leading)

                        Spacer()
                        ActionButtonsStack(
                            video: $video,
                            onLikeTap: {
                                likesStore.toggleLike(videoId: video.id)
                            },
                            onBookmarkTap: {
                                likesStore.toggleBookmark(videoId: video.id)
                            }
                        )
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            // Sync like state from persistence
            video.isLiked = likesStore.isLiked(videoId: video.id)
            video.isBookmarked = likesStore.isBookmarked(videoId: video.id)
        }
    }
}

