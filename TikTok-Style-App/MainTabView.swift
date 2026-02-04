//
//  MainTabView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var isFeedVisible: Bool = true

    private var isDarkMode: Bool {
        selectedTab == .home || selectedTab == .create || selectedTab == .search || selectedTab == .shop
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            FeedView(
                isTabVisible: isFeedVisible,
                onProfileTap: { selectedTab = .profile }
            )
            .opacity(selectedTab == .home ? 1 : 0)
            .zIndex(selectedTab == .home ? 1 : 0)

            ProfileView()
                .opacity(selectedTab == .profile ? 1 : 0)
                .zIndex(selectedTab == .profile ? 1 : 0)

            PlaceholderView(title: "Search", icon: "magnifyingglass")
                .opacity(selectedTab == .search ? 1 : 0)
                .zIndex(selectedTab == .search ? 1 : 0)

            PlaceholderView(title: "Create", icon: "plus")
                .opacity(selectedTab == .create ? 1 : 0)
                .zIndex(selectedTab == .create ? 1 : 0)

            PlaceholderView(title: "Shop", icon: "bag")
                .opacity(selectedTab == .shop ? 1 : 0)
                .zIndex(selectedTab == .shop ? 1 : 0)

            CustomTabBar(selectedTab: $selectedTab, isDarkMode: isDarkMode)
                .zIndex(100)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selectedTab) { oldValue, newValue in
            isFeedVisible = (newValue == .home)
        }
    }
}


private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text(title)
                .font(.title2)
                .foregroundColor(.gray)

            Text("Coming Soon")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundLight)
    }
}

#Preview {
    MainTabView()
}
