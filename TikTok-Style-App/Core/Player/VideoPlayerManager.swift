//
//  VideoPlayerManager.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import AVFoundation
import Combine

// MARK: - Video Player Manager
/// Manages video players efficiently - only keeps active players for visible + adjacent cells
final class VideoPlayerManager: ObservableObject {

    static let shared = VideoPlayerManager()

    // MARK: - Properties
    private var players: [Int: AVPlayer] = [:]
    private var playerItems: [Int: AVPlayerItem] = [:]
    private var loopObservers: [Int: Any] = [:]

    private let maxCachedPlayers = 3

    // MARK: - Published State
    @Published var currentlyPlayingId: Int?

    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.mixWithOthers, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            print("AudioSession- Audio session configured successfully")
        } catch {
            print("AudioSession- Failed to setup audio session: \(error)")
        }
    }

    /// Call this to re-activate audio session (e.g., when app returns to foreground)
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession- Failed to activate audio session: \(error)")
        }
    }

    // MARK: - Get or Create Player
    func player(for videoId: Int, url: URL) -> AVPlayer {
        // Return existing player if available
        if let existingPlayer = players[videoId] {
            return existingPlayer
        }

        // Create new player
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        player.isMuted = false
        player.volume = 1.0

        players[videoId] = player
        playerItems[videoId] = playerItem

        // Setup looping
        setupLooping(for: videoId, player: player)

        // Cleanup if too many players cached
        cleanupIfNeeded(currentId: videoId)

        return player
    }

    // MARK: - Looping
    private func setupLooping(for videoId: Int, player: AVPlayer) {
        // Remove existing observer
        if let observer = loopObservers[videoId] {
            NotificationCenter.default.removeObserver(observer)
        }

        // Add loop observer
        let observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        loopObservers[videoId] = observer
    }

    // MARK: - Playback Control
    func play(videoId: Int) {
        // Pause current video
        if let currentId = currentlyPlayingId, currentId != videoId {
            players[currentId]?.pause()
        }

        // Play new video
        players[videoId]?.seek(to: .zero)
        players[videoId]?.play()
        currentlyPlayingId = videoId
    }

    func pause(videoId: Int) {
        players[videoId]?.pause()
        if currentlyPlayingId == videoId {
            currentlyPlayingId = nil
        }
    }

    func pauseAll() {
        players.values.forEach { $0.pause() }
        currentlyPlayingId = nil
    }

    // MARK: - Cleanup
    private func cleanupIfNeeded(currentId: Int) {
        guard players.count > maxCachedPlayers else { return }

        // Keep current and adjacent players, remove others
        let idsToKeep = Set([currentId - 1, currentId, currentId + 1])

        for (id, player) in players where !idsToKeep.contains(id) {
            player.pause()
            player.replaceCurrentItem(with: nil)

            if let observer = loopObservers[id] {
                NotificationCenter.default.removeObserver(observer)
            }

            players.removeValue(forKey: id)
            playerItems.removeValue(forKey: id)
            loopObservers.removeValue(forKey: id)
        }
    }

    func releasePlayer(for videoId: Int) {
        players[videoId]?.pause()
        players[videoId]?.replaceCurrentItem(with: nil)

        if let observer = loopObservers[videoId] {
            NotificationCenter.default.removeObserver(observer)
        }

        players.removeValue(forKey: videoId)
        playerItems.removeValue(forKey: videoId)
        loopObservers.removeValue(forKey: videoId)
    }

    func releaseAll() {
        pauseAll()
        players.values.forEach { $0.replaceCurrentItem(with: nil) }

        loopObservers.values.forEach {
            NotificationCenter.default.removeObserver($0)
        }

        players.removeAll()
        playerItems.removeAll()
        loopObservers.removeAll()
    }

    // MARK: - Preloading
    func preload(videoId: Int, url: URL) {
        guard players[videoId] == nil else { return }

        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            DispatchQueue.main.async {
                _ = self?.player(for: videoId, url: url)
            }
        }
    }
}
