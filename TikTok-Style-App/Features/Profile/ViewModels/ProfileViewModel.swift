//
//  ProfileViewModel.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {

    @Published private(set) var profile: UserProfile = .default
    @Published private(set) var videos: [Video] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // Store all fetched videos to filter for liked/saved
    @Published private(set) var allFetchedVideos: [Video] = []


    private let videoService: VideoServiceProtocol
    private let likesStore: LikesStore
    private let videoCache: VideoCache
    private var cancellables = Set<AnyCancellable>()
    
    
  
    init(
        videoService: VideoServiceProtocol = VideoService.shared,
        likesStore: LikesStore = .shared,
        videoCache: VideoCache = .shared
    ) {
        self.videoService = videoService
        self.likesStore = likesStore
        self.videoCache = videoCache
        observeLikesChanges()
    }
    
    

    // MARK: - Computed Properties
    var totalLikes: Int {
        likesStore.likedIds.count
    }

    var videoCount: Int {
        videos.count
    }

    var likedVideos: [Video] {
        // Get liked videos from cache and sync state
        let cachedVideos = videoCache.videos(for: likesStore.likedIds)
        print("[ProfileVM] Liked IDs: \(likesStore.likedIds)")
        print("[ProfileVM] Cached videos count: \(cachedVideos.count)")
        return cachedVideos.map { video in
            var updated = video
            updated.isLiked = true
            updated.isBookmarked = likesStore.isBookmarked(videoId: video.id)
            return updated
        }
    }

    var savedVideos: [Video] {
        // Get saved videos from cache and sync state
        videoCache.videos(for: likesStore.bookmarkedIds).map { video in
            var updated = video
            updated.isLiked = likesStore.isLiked(videoId: video.id)
            updated.isBookmarked = true
            return updated
        }
    }

    

    /// Fetch random videos for the profile grid
    func fetchProfileVideos() async {
        guard !isLoading else { return }

        print("[ProfileVM] Fetching profile videos...")
        isLoading = true
        error = nil

        do {
            // Fetch videos from a random page for variety
            let randomPage = Int.random(in: 1...3)
            let fetchedVideos = try await videoService.fetchVideos(
                query: APIConfiguration.defaultQuery,
                page: randomPage,
                perPage: 30
            )

            // Shuffle to make it feel like "user's videos"
            videos = fetchedVideos.shuffled()

            // Store all videos for liked/saved filtering
            allFetchedVideos = fetchedVideos

            // Cache videos for cross-screen access
            videoCache.cache(videos: fetchedVideos)

            // Update profile with real counts
            updateProfileCounts()

            print("[ProfileVM] Loaded \(videos.count) profile videos")
        } catch {
            self.error = error
            print("[ProfileVM] Error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Refresh profile data
    func refresh() async {
        videos = []
        allFetchedVideos = []
        await fetchProfileVideos()
    }

    /// Get video at index for playback
    func video(at index: Int) -> Video? {
        guard index >= 0 && index < videos.count else { return nil }
        return videos[index]
    }

    /// Get videos for a specific tab with synced like/bookmark state
    func videos(for tab: ProfileTab) -> [Video] {
        switch tab {
        case .videos:
            return videos.map { syncState(for: $0) }
        case .liked:
            return likedVideos
        case .saved:
            return savedVideos
        case .locked:
            return [] // Private videos - not implemented
        }
    }

    /// Sync like/bookmark state from LikesStore
    private func syncState(for video: Video) -> Video {
        var updated = video
        updated.isLiked = likesStore.isLiked(videoId: video.id)
        updated.isBookmarked = likesStore.isBookmarked(videoId: video.id)
        return updated
    }

    // MARK: - Private Methods

    private func observeLikesChanges() {
        // Observe liked changes
        likesStore.$likedIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProfileCounts()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Observe bookmarked changes
        likesStore.$bookmarkedIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func updateProfileCounts() {
        profile.videoCount = videos.count
    }
}

// MARK: - Profile Video Extension
extension Video {
    /// Convert to a simpler profile video representation
    var asProfileVideo: ProfileVideo {
        ProfileVideo(
            id: id,
            thumbnailURL: thumbnailURL,
            viewCount: likeCount + commentCount + shareCount,
            isPinned: false
        )
    }
}
