//
//  ActionButtonsStack.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ActionButtonsStack: View {
    @Binding var video: Video
    var onLikeTap: () -> Void = {}
    var onBookmarkTap: () -> Void = {}
    var onCommentTap: () -> Void = {}
    var onShareTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            // Like Button
            ActionButton(
                icon: "heart",
                activeIcon: "heart.fill",
                count: video.likeCount,
                isActive: video.isLiked,
                activeColor: .likePink
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    video.isLiked.toggle()
                    video.likeCount += video.isLiked ? 1 : -1
                }
                onLikeTap()
            }

            // Comment Button
            ActionButton(
                icon: "ellipsis.bubble",
                count: video.commentCount
            ) {
                onCommentTap()
            }

            // Share Button
            ActionButton(
                icon: "arrowshape.turn.up.right",
                count: video.shareCount
            ) {
                onShareTap()
            }

            // Bookmark Button
            ActionButton(
                icon: "bookmark",
                activeIcon: "bookmark.fill",
                count: video.bookmarkCount,
                isActive: video.isBookmarked,
                activeColor: .accentYellow
            ) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    video.isBookmarked.toggle()
                    video.bookmarkCount += video.isBookmarked ? 1 : -1
                }
                onBookmarkTap()
            }
        }
    }
}

