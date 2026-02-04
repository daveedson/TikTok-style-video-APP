//
//  LikesStore.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation
import Combine

// MARK: - Likes Store Protocol
protocol LikesStoreProtocol {
    func isLiked(videoId: Int) -> Bool
    func toggleLike(videoId: Int) -> Bool
    func setLiked(videoId: Int, isLiked: Bool)
    func likedVideoIds() -> Set<Int>
}

// MARK: - Likes Store
/// Persists liked video IDs using UserDefaults
final class LikesStore: LikesStoreProtocol, ObservableObject {

    static let shared = LikesStore()

    // MARK: - Keys
    private enum Keys {
        static let likedVideos = "liked_video_ids"
        static let bookmarkedVideos = "bookmarked_video_ids"
    }

    // MARK: - Properties
    private let defaults: UserDefaults
    @Published private(set) var likedIds: Set<Int> = []
    @Published private(set) var bookmarkedIds: Set<Int> = []

    // MARK: - Initialization
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadFromStorage()
    }

    // MARK: - Load from Storage
    private func loadFromStorage() {
        if let likedArray = defaults.array(forKey: Keys.likedVideos) as? [Int] {
            likedIds = Set(likedArray)
        }

        if let bookmarkedArray = defaults.array(forKey: Keys.bookmarkedVideos) as? [Int] {
            bookmarkedIds = Set(bookmarkedArray)
        }
    }

    // MARK: - Save to Storage
    private func saveLikes() {
        defaults.set(Array(likedIds), forKey: Keys.likedVideos)
    }

    private func saveBookmarks() {
        defaults.set(Array(bookmarkedIds), forKey: Keys.bookmarkedVideos)
    }

    // MARK: - Likes
    func isLiked(videoId: Int) -> Bool {
        likedIds.contains(videoId)
    }

    @discardableResult
    func toggleLike(videoId: Int) -> Bool {
        if likedIds.contains(videoId) {
            likedIds.remove(videoId)
            saveLikes()
            return false
        } else {
            likedIds.insert(videoId)
            saveLikes()
            return true
        }
    }

    func setLiked(videoId: Int, isLiked: Bool) {
        if isLiked {
            likedIds.insert(videoId)
        } else {
            likedIds.remove(videoId)
        }
        saveLikes()
    }

    func likedVideoIds() -> Set<Int> {
        likedIds
    }

    // MARK: - Bookmarks
    func isBookmarked(videoId: Int) -> Bool {
        bookmarkedIds.contains(videoId)
    }

    @discardableResult
    func toggleBookmark(videoId: Int) -> Bool {
        if bookmarkedIds.contains(videoId) {
            bookmarkedIds.remove(videoId)
            saveBookmarks()
            return false
        } else {
            bookmarkedIds.insert(videoId)
            saveBookmarks()
            return true
        }
    }

    func setBookmarked(videoId: Int, isBookmarked: Bool) {
        if isBookmarked {
            bookmarkedIds.insert(videoId)
        } else {
            bookmarkedIds.remove(videoId)
        }
        saveBookmarks()
    }

    func bookmarkedVideoIds() -> Set<Int> {
        bookmarkedIds
    }

    // MARK: - Clear All
    func clearAll() {
        likedIds.removeAll()
        bookmarkedIds.removeAll()
        defaults.removeObject(forKey: Keys.likedVideos)
        defaults.removeObject(forKey: Keys.bookmarkedVideos)
    }
}
