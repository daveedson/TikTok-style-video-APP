//
//  ProfileView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var likesStore = LikesStore.shared
    @State private var selectedTab: ProfileTab = .videos
    @State private var selectedVideo: Video?

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavigationBar(username: viewModel.profile.username)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    ProfileHeaderView(
                        profile: profileWithCounts,
                        likesCount: likesStore.likedIds.count
                    )
                    .padding(.top, 8)

                    ProfileTabsView(selectedTab: $selectedTab)

                    if viewModel.isLoading && viewModel.videos.isEmpty {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let error = viewModel.error, viewModel.videos.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Failed to load videos")
                                .foregroundColor(.textSecondary)
                            Button("Retry") {
                                Task { await viewModel.fetchProfileVideos() }
                            }
                            .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                    } else {
                        let videosForTab = viewModel.videos(for: selectedTab)

                        if videosForTab.isEmpty {
                            emptyStateView(for: selectedTab)
                        } else {
                            ProfileVideoGrid(
                                videos: videosForTab,
                                onVideoTap: { video in
                                    print("[Profile] Tapped video: \(video.id)")
                                    selectedVideo = video
                                }
                            )
                            .padding(.horizontal, 2)
                        }
                    }
                }
            }
        }
        .background(Color.backgroundLight)
        .task {
            await viewModel.fetchProfileVideos()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .fullScreenCover(item: $selectedVideo) { video in
            ProfileVideoPlayerView(
                video: video,
                onDismiss: { selectedVideo = nil }
            )
        }
    }

    private var profileWithCounts: UserProfile {
        var profile = viewModel.profile
        profile.videoCount = viewModel.videos.count
        return profile
    }

    @ViewBuilder
    private func emptyStateView(for tab: ProfileTab) -> some View {
        VStack(spacing: 16) {
            Image(systemName: emptyStateIcon(for: tab))
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))

            Text(emptyStateTitle(for: tab))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)

            Text(emptyStateSubtitle(for: tab))
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 40)
    }

    private func emptyStateIcon(for tab: ProfileTab) -> String {
        switch tab {
        case .videos: return "video.slash"
        case .liked: return "heart"
        case .saved: return "bookmark"
        case .locked: return "lock"
        }
    }

    private func emptyStateTitle(for tab: ProfileTab) -> String {
        switch tab {
        case .videos: return "No videos yet"
        case .liked: return "No liked videos"
        case .saved: return "No saved videos"
        case .locked: return "No private videos"
        }
    }

    private func emptyStateSubtitle(for tab: ProfileTab) -> String {
        switch tab {
        case .videos: return "Videos you create will appear here"
        case .liked: return "Videos you like will appear here"
        case .saved: return "Videos you bookmark will appear here"
        case .locked: return "Private videos will appear here"
        }
    }
}


struct ProfileNavigationBar: View {
    let username: String
    var onAddFriend: () -> Void = {}
    var onMenu: () -> Void = {}

    var body: some View {
        HStack {
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text(username)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 20) {
                Button(action: onAddFriend) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 22))
                        .foregroundColor(.textPrimary)
                }
                .buttonStyle(.plain)

                Button(action: onMenu) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 22))
                        .foregroundColor(.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.backgroundLight)
    }
}

#Preview {
    ProfileView()
}
