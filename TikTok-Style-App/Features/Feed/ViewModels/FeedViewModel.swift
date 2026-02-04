//
//  FeedViewModel.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation
import Combine

@MainActor
class FeedViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var videos: [Video] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var currentIndex: Int = 0

    // MARK: - Private Properties
    private let videoService: VideoServiceProtocol
    private let videoCache: VideoCache
    private var currentPage = 1
    private var hasMorePages = true

    // MARK: - Initialization
    init(
        videoService: VideoServiceProtocol = VideoService.shared,
        videoCache: VideoCache = .shared
    ) {
        self.videoService = videoService
        self.videoCache = videoCache
    }

    // MARK: - Public Methods

    /// Fetch initial videos
    func fetchVideos() async {
        guard !isLoading else {
            print("[FeedVM] Already loading, skipping fetch")
            return
        }

        print("[FeedVM] Fetching videos - Page: 1")
        isLoading = true
        error = nil
        currentPage = 1

        do {
            let fetchedVideos = try await videoService.fetchVideos(
                query: APIConfiguration.defaultQuery,
                page: currentPage,
                perPage: APIConfiguration.perPage
            )
            videos = fetchedVideos
            hasMorePages = !fetchedVideos.isEmpty
            videoCache.cache(videos: fetchedVideos)
            print("[FeedVM] Fetched \(fetchedVideos.count) videos, Total: \(videos.count)")
        } catch {
            self.error = error
            print("[FeedVM] Fetch error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Load more videos for pagination
    func loadMoreVideosIfNeeded(currentVideo: Video) async {
        // Check if we're near the end (3 videos before last)
        guard let index = videos.firstIndex(where: { $0.id == currentVideo.id }),
              index >= videos.count - 3,
              hasMorePages,
              !isLoading else {
            return
        }

        print("[FeedVM] Near end of list (index: \(index)/\(videos.count)), loading more...")
        await loadNextPage()
    }

    /// Load next page
    func loadNextPage() async {
        guard !isLoading, hasMorePages else {
            print("[FeedVM] Skipping loadNextPage - isLoading: \(isLoading), hasMorePages: \(hasMorePages)")
            return
        }

        currentPage += 1
        print("[FeedVM] Loading page \(currentPage)...")
        isLoading = true

        do {
            let newVideos = try await videoService.fetchVideos(
                query: APIConfiguration.defaultQuery,
                page: currentPage,
                perPage: APIConfiguration.perPage
            )

            if newVideos.isEmpty {
                hasMorePages = false
                print("[FeedVM] No more videos available")
            } else {
                videos.append(contentsOf: newVideos)
                videoCache.cache(videos: newVideos)
                print("[FeedVM] Loaded \(newVideos.count) more videos, Total: \(videos.count)")
            }
        } catch {
            self.error = error
            currentPage -= 1
            print("[FeedVM] LoadNextPage error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Refresh videos
    func refresh() async {
        print("[FeedVM] Refreshing feed...")
        videos = []
        currentPage = 1
        hasMorePages = true
        await fetchVideos()
    }

    /// Toggle like for a video
    func toggleLike(for video: Video) {
        guard let index = videos.firstIndex(where: { $0.id == video.id }) else { return }
        videos[index].isLiked.toggle()
        videos[index].likeCount += videos[index].isLiked ? 1 : -1
    }

    /// Toggle bookmark for a video
    func toggleBookmark(for video: Video) {
        guard let index = videos.firstIndex(where: { $0.id == video.id }) else { return }
        videos[index].isBookmarked.toggle()
        videos[index].bookmarkCount += videos[index].isBookmarked ? 1 : -1
    }

    /// Get binding for a video at index
    func binding(for index: Int) -> Video {
        guard index < videos.count else { return videos[0] }
        return videos[index]
    }

    /// Update a video at index
    func updateVideo(at index: Int, with video: Video) {
        guard index >= 0 && index < videos.count else { return }
        videos[index] = video
        // Also update the cache
        VideoCache.shared.cache(video: video)
    }
}
