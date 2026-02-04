//
//  FeedView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct FeedView: View {
    var isTabVisible: Bool = true
    var onProfileTap: () -> Void = {}

    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedTab: FeedTab = .forYou

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if viewModel.isLoading && viewModel.videos.isEmpty {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if let error = viewModel.error, viewModel.videos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Failed to load videos")
                            .foregroundColor(.white)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchVideos()
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                                VideoFeedCell(
                                    video: Binding(
                                        get: { viewModel.videos[index] },
                                        set: { viewModel.updateVideo(at: index, with: $0) }
                                    ),
                                    isVisible: viewModel.currentIndex == index && isTabVisible,
                                    onUsernameTap: onProfileTap
                                )
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .id(index)
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreVideosIfNeeded(currentVideo: video)
                                    }
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: Binding(
                        get: { viewModel.currentIndex },
                        set: { if let newValue = $0 { viewModel.currentIndex = newValue } }
                    ))
                    .ignoresSafeArea()
                }

                VStack {
                    FeedHeaderView(selectedTab: $selectedTab)
                        .padding(.top, proxy.safeAreaInsets.top + 20)

                    Spacer()
                }
            }
        }
        .background(Color.backgroundDark)
        .ignoresSafeArea()
        .task {
            await viewModel.fetchVideos()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    FeedView()
}
