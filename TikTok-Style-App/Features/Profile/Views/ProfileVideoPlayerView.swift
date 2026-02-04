//
//  ProfileVideoPlayerView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ProfileVideoPlayerView: View {
    let video: Video
    var onDismiss: () -> Void

    @State private var videoBinding: Video
    @StateObject private var likesStore = LikesStore.shared

    init(video: Video, onDismiss: @escaping () -> Void) {
        self.video = video
        self.onDismiss = onDismiss
        // Sync state from LikesStore at init time
        var syncedVideo = video
        syncedVideo.isLiked = LikesStore.shared.isLiked(videoId: video.id)
        syncedVideo.isBookmarked = LikesStore.shared.isBookmarked(videoId: video.id)
        self._videoBinding = State(initialValue: syncedVideo)
    }

    @StateObject private var playerManager = VideoPlayerManager.shared
    @State private var isPlaying = true
    @State private var showPauseIcon = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { proxy in
                ZStack {
                    // Video Player - tap gesture disabled
                    VideoPlayerView(
                        videoId: video.id,
                        videoURL: video.videoURL,
                        thumbnailURL: video.thumbnailURL,
                        isVisible: true,
                        showTapToToggle: false
                    )
                    .allowsHitTesting(false)

                   
                    if showPauseIcon {
                        Image(systemName: isPlaying ? "play.fill" : "pause.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.8))
                    }

     
                    VStack {
                        Spacer()
                        LinearGradient.videoOverlayGradient
                            .frame(height: proxy.size.height * 0.4)
                    }
                    .allowsHitTesting(false)

                  
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom, spacing: 12) {
                            VideoOverlayView(
                                video: video,
                                onUsernameTap: {}
                            )
                            .frame(maxWidth: proxy.size.width * 0.7, alignment: .leading)

                            Spacer()

                            ActionButtonsStack(
                                video: $videoBinding,
                                onLikeTap: {
                                    likesStore.toggleLike(videoId: video.id)
                                    videoBinding.isLiked = likesStore.isLiked(videoId: video.id)
                                },
                                onBookmarkTap: {
                                    likesStore.toggleBookmark(videoId: video.id)
                                    videoBinding.isBookmarked = likesStore.isBookmarked(videoId: video.id)
                                }
                            )
                            .padding(.bottom, 20)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
               
                .contentShape(Rectangle())
                .onTapGesture {
                    togglePlayPause()
                }
            }

           
            VStack {
                HStack {
                    Button(action: {
                        onDismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 60)
                Spacer()
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
        .onAppear {
            print("[ProfilePlayer] Opening video: \(video.id)")
            print("[ProfilePlayer] URL: \(video.videoURL)")
            videoBinding.isLiked = likesStore.isLiked(videoId: video.id)
            videoBinding.isBookmarked = likesStore.isBookmarked(videoId: video.id)
        }
    }

    private func togglePlayPause() {
        if isPlaying {
            playerManager.pause(videoId: video.id)
        } else {
            playerManager.play(videoId: video.id)
        }
        isPlaying.toggle()
        withAnimation(.easeInOut(duration: 0.2)) {
            showPauseIcon = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showPauseIcon = false
            }
        }
    }
}

