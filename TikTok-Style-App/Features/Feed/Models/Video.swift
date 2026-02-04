//
//  Video.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation

struct Video: Identifiable, Equatable {
    let id: Int
    let user: VideoUser
    let videoURL: URL
    let thumbnailURL: URL?
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var bookmarkCount: Int
    var isLiked: Bool = false
    var isBookmarked: Bool = false
    let caption: String?
    let musicTitle: String?
}

struct VideoUser: Equatable {
    let id: Int
    let name: String
    let username: String
    let avatarURL: URL?
}

