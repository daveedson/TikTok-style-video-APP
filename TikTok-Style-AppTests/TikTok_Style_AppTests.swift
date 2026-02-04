//
//  TikTok_Style_AppTests.swift
//  TikTok-Style-AppTests
//
//  Created by DavidOnoh on 2/1/26.
//

import XCTest
@testable import TikTok_Style_App

// MARK: - JSON Parsing Tests
final class JSONParsingTests: XCTestCase {

    func testPexelsVideoResponseParsing() throws {
        // Given: Sample JSON response from Pexels API
        let json = """
        {
            "page": 1,
            "per_page": 15,
            "total_results": 1000,
            "url": "https://api.pexels.com/videos/search?query=nature",
            "videos": [
                {
                    "id": 12345,
                    "width": 1920,
                    "height": 1080,
                    "url": "https://www.pexels.com/video/12345",
                    "image": "https://images.pexels.com/videos/12345/thumbnail.jpg",
                    "duration": 30,
                    "user": {
                        "id": 100,
                        "name": "John Doe",
                        "url": "https://www.pexels.com/@johndoe"
                    },
                    "video_files": [
                        {
                            "id": 1,
                            "quality": "hd",
                            "file_type": "video/mp4",
                            "width": 1920,
                            "height": 1080,
                            "fps": 30.0,
                            "link": "https://videos.pexels.com/12345/hd.mp4"
                        }
                    ],
                    "video_pictures": [
                        {
                            "id": 1,
                            "picture": "https://images.pexels.com/videos/12345/pic1.jpg",
                            "nr": 0
                        }
                    ]
                }
            ],
            "next_page": "https://api.pexels.com/videos/search?page=2"
        }
        """.data(using: .utf8)!

        // When: Decoding the JSON
        let decoder = JSONDecoder()
        let response = try decoder.decode(PexelsVideoResponse.self, from: json)

        // Then: Verify parsed values
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.perPage, 15)
        XCTAssertEqual(response.totalResults, 1000)
        XCTAssertEqual(response.videos.count, 1)

        let video = response.videos[0]
        XCTAssertEqual(video.id, 12345)
        XCTAssertEqual(video.width, 1920)
        XCTAssertEqual(video.height, 1080)
        XCTAssertEqual(video.duration, 30)
        XCTAssertEqual(video.user.name, "John Doe")
        XCTAssertEqual(video.videoFiles.count, 1)
        XCTAssertEqual(video.videoFiles[0].quality, "hd")
    }

    func testPexelsVideoToDomainModel() throws {
        // Given: A PexelsVideo object
        let pexelsVideo = PexelsVideo(
            id: 999,
            width: 1080,
            height: 1920,
            url: "https://pexels.com/video/999",
            image: "https://images.pexels.com/999.jpg",
            duration: 15,
            user: PexelsUser(id: 1, name: "Test User", url: "https://pexels.com/@testuser"),
            videoFiles: [
                PexelsVideoFile(id: 1, quality: "hd", fileType: "video/mp4", width: 1080, height: 1920, fps: 30, link: "https://videos.pexels.com/999.mp4")
            ],
            videoPictures: []
        )

        // When: Converting to domain model
        let video = pexelsVideo.toDomainModel()

        // Then: Verify conversion
        XCTAssertEqual(video.id, 999)
        XCTAssertEqual(video.user.name, "Test User")
        XCTAssertEqual(video.user.username, "test_user")
        XCTAssertEqual(video.videoURL.absoluteString, "https://videos.pexels.com/999.mp4")
        XCTAssertNotNil(video.thumbnailURL)
    }

    func testParsingWithMissingOptionalFields() throws {
        // Given: JSON with missing optional fields
        let json = """
        {
            "page": 1,
            "per_page": 10,
            "total_results": 100,
            "videos": [
                {
                    "id": 1,
                    "width": 1920,
                    "height": 1080,
                    "url": "https://pexels.com/video/1",
                    "image": "https://images.pexels.com/1.jpg",
                    "duration": 10,
                    "user": {
                        "id": 1,
                        "name": "User",
                        "url": "https://pexels.com/@user"
                    },
                    "video_files": [
                        {
                            "id": 1,
                            "link": "https://videos.pexels.com/1.mp4"
                        }
                    ],
                    "video_pictures": []
                }
            ]
        }
        """.data(using: .utf8)!

        // When: Decoding
        let decoder = JSONDecoder()
        let response = try decoder.decode(PexelsVideoResponse.self, from: json)

        // Then: Should parse successfully with nil optionals
        XCTAssertNil(response.url)
        XCTAssertNil(response.nextPage)
        XCTAssertNil(response.videos[0].videoFiles[0].quality)
        XCTAssertNil(response.videos[0].videoFiles[0].fileType)
    }
}

// MARK: - LikesStore Tests
final class LikesStoreTests: XCTestCase {

    var likesStore: LikesStore!

    override func setUp() {
        super.setUp()
        // Create a fresh instance for testing
        likesStore = LikesStore.shared
        // Clear any existing data
        likesStore.clearAll()
    }

    override func tearDown() {
        likesStore.clearAll()
        super.tearDown()
    }

    func testToggleLike() {
        // Given: A video ID
        let videoId = 12345

        // Initially not liked
        XCTAssertFalse(likesStore.isLiked(videoId: videoId))

        // When: Toggle like
        likesStore.toggleLike(videoId: videoId)

        // Then: Should be liked
        XCTAssertTrue(likesStore.isLiked(videoId: videoId))
        XCTAssertTrue(likesStore.likedIds.contains(videoId))

        // When: Toggle again
        likesStore.toggleLike(videoId: videoId)

        // Then: Should be unliked
        XCTAssertFalse(likesStore.isLiked(videoId: videoId))
    }

    func testToggleBookmark() {
        // Given: A video ID
        let videoId = 67890

        // Initially not bookmarked
        XCTAssertFalse(likesStore.isBookmarked(videoId: videoId))

        // When: Toggle bookmark
        likesStore.toggleBookmark(videoId: videoId)

        // Then: Should be bookmarked
        XCTAssertTrue(likesStore.isBookmarked(videoId: videoId))
        XCTAssertTrue(likesStore.bookmarkedIds.contains(videoId))

        // When: Toggle again
        likesStore.toggleBookmark(videoId: videoId)

        // Then: Should be unbookmarked
        XCTAssertFalse(likesStore.isBookmarked(videoId: videoId))
    }

    func testMultipleLikes() {
        // Given: Multiple video IDs
        let videoIds = [1, 2, 3, 4, 5]

        // When: Like all videos
        for id in videoIds {
            likesStore.toggleLike(videoId: id)
        }

        // Then: All should be liked
        XCTAssertEqual(likesStore.likedIds.count, 5)
        for id in videoIds {
            XCTAssertTrue(likesStore.isLiked(videoId: id))
        }
    }

    func testLikeAndBookmarkSameVideo() {
        // Given: A video ID
        let videoId = 11111

        // When: Like and bookmark the same video
        likesStore.toggleLike(videoId: videoId)
        likesStore.toggleBookmark(videoId: videoId)

        // Then: Both should be true
        XCTAssertTrue(likesStore.isLiked(videoId: videoId))
        XCTAssertTrue(likesStore.isBookmarked(videoId: videoId))

        // When: Unlike but keep bookmark
        likesStore.toggleLike(videoId: videoId)

        // Then: Only bookmark should remain
        XCTAssertFalse(likesStore.isLiked(videoId: videoId))
        XCTAssertTrue(likesStore.isBookmarked(videoId: videoId))
    }
}

// MARK: - Video Model Tests
final class VideoModelTests: XCTestCase {

    func testVideoInitialization() {
        // Given: Video properties
        let video = Video(
            id: 1,
            user: VideoUser(id: 1, name: "Test", username: "test", avatarURL: nil),
            videoURL: URL(string: "https://example.com/video.mp4")!,
            thumbnailURL: URL(string: "https://example.com/thumb.jpg"),
            likeCount: 100,
            commentCount: 50,
            shareCount: 25,
            bookmarkCount: 10,
            caption: "Test caption",
            musicTitle: "Test Song"
        )

        // Then: Properties should match
        XCTAssertEqual(video.id, 1)
        XCTAssertEqual(video.user.username, "test")
        XCTAssertEqual(video.likeCount, 100)
        XCTAssertEqual(video.caption, "Test caption")
        XCTAssertFalse(video.isLiked)
        XCTAssertFalse(video.isBookmarked)
    }

    func testVideoLikeState() {
        // Given: A video
        var video = Video(
            id: 1,
            user: VideoUser(id: 1, name: "Test", username: "test", avatarURL: nil),
            videoURL: URL(string: "https://example.com/video.mp4")!,
            thumbnailURL: nil,
            likeCount: 100,
            commentCount: 0,
            shareCount: 0,
            bookmarkCount: 0,
            caption: "",
            musicTitle: ""
        )

        // Initially not liked
        XCTAssertFalse(video.isLiked)

        // When: Set liked
        video.isLiked = true

        // Then: Should be liked
        XCTAssertTrue(video.isLiked)
    }
}
