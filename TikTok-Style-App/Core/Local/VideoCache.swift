//
//  VideoCache.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation
import Combine

/// Shared cache for videos that have been viewed/interacted with
/// This allows the Profile to show liked/saved videos from the feed
@MainActor
final class VideoCache: ObservableObject {

    static let shared = VideoCache()

    // MARK: - Published Properties
    @Published private(set) var cachedVideos: [Int: Video] = [:]

    // MARK: - Public Methods

    /// Add a video to the cache
    func cache(video: Video) {
        cachedVideos[video.id] = video
    }

    /// Add multiple videos to the cache
    func cache(videos: [Video]) {
        for video in videos {
            cachedVideos[video.id] = video
        }
    }

    /// Get a video from cache by ID
    func video(for id: Int) -> Video? {
        cachedVideos[id]
    }

    /// Get all cached videos
    var allVideos: [Video] {
        Array(cachedVideos.values)
    }

    /// Get videos by their IDs
    func videos(for ids: Set<Int>) -> [Video] {
        ids.compactMap { cachedVideos[$0] }
    }

    /// Clear the cache
    func clear() {
        cachedVideos.removeAll()
    }
}
