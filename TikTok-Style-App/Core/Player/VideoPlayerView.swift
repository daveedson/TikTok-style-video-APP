//
//  VideoPlayerView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI
import AVFoundation

struct VideoPlayerView: View {
    let videoId: Int
    let videoURL: URL
    let thumbnailURL: URL?
    let isVisible: Bool
    var showTapToToggle: Bool = true

    @State private var player: AVPlayer?
    @State private var isBuffering = true
    @State private var isPausedByUser = false
    @State private var showPauseIcon = false

    private let playerManager = VideoPlayerManager.shared

    var body: some View {
        ZStack {
            // Video layer
            if let player = player {
                PlayerView(player: player)
                    .ignoresSafeArea()
            }

            // Loading indicator - show while buffering
            if isBuffering {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }

            // Tap to toggle play/pause
            if showTapToToggle {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { togglePlayPause() }
            }

            // Pause icon - only show when user explicitly paused
            if isPausedByUser || showPauseIcon {
                Image(systemName: isPausedByUser ? "pause.fill" : "play.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.8))
                    .allowsHitTesting(false)
            }
        }
        .background(Color.black)
        .onAppear {
            setupAndPlay()
        }
        .onChange(of: isVisible) { _, visible in
            if visible {
                isPausedByUser = false
                play()
            } else {
                player?.pause()
            }
        }
        .onDisappear {
            player?.pause()
        }
    }

    private func setupAndPlay() {
        player = playerManager.player(for: videoId, url: videoURL)

        // Observe buffering state
        observeBuffering()

        // Start playing if visible
        if isVisible {
            play()
        }
    }

    private func observeBuffering() {
        guard let player = player, let item = player.currentItem else { return }

        // Check periodically if playback is ready
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if item.status == .readyToPlay && item.isPlaybackLikelyToKeepUp {
                DispatchQueue.main.async {
                    isBuffering = false
                }
                timer.invalidate()
            }
        }
    }

    private func play() {
        playerManager.play(videoId: videoId)
    }

    private func togglePlayPause() {
        guard let player = player else { return }

        if player.rate > 0 {
            player.pause()
            isPausedByUser = true
        } else {
            player.play()
            isPausedByUser = false
        }

        showPauseIcon = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showPauseIcon = false
        }
    }
}

// MARK: - Player UIView Wrapper
struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.player = player
    }
}

class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    var player: AVPlayer? {
        get { playerLayer.player }
        set {
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}
