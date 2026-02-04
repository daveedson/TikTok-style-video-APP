//
//  UserProfile.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation

struct UserProfile: Identifiable {
    let id: Int
    let username: String
    let displayName: String
    let bio: String
    let avatarURL: URL?
    let badge: String?
    var videoCount: Int
    var followerCount: Int
    var followingCount: Int
    var isCurrentUser: Bool
}

extension UserProfile {
    static let `default` = UserProfile(
        id: 1,
        username: "Daveedson",
        displayName: "David Onoh",
        bio: "Capturing every moment one frame at a time. 📸✨",
        avatarURL: nil,
        badge: nil,
        videoCount: 0,
        followerCount: 0,
        followingCount: 0,
        isCurrentUser: true
    )
}

// MARK: - Profile Video (for grid)
struct ProfileVideo: Identifiable {
    let id: Int
    let thumbnailURL: URL?
    let viewCount: Int
    let isPinned: Bool
}
