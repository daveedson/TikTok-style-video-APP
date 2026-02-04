//
//  ProfileTabsView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

enum ProfileTab: Int, CaseIterable {
    case videos
    case locked
    case saved
    case liked

    var icon: String {
        switch self {
        case .videos: return "square.grid.2x2"
        case .locked: return "lock"
        case .saved: return "bookmark"
        case .liked: return "heart"
        }
    }

    var selectedIcon: String {
        switch self {
        case .videos: return "square.grid.2x2.fill"
        case .locked: return "lock.fill"
        case .saved: return "bookmark.fill"
        case .liked: return "heart.fill"
        }
    }
}

struct ProfileTabsView: View {
    @Binding var selectedTab: ProfileTab

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    ProfileTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 0.5)
        }
    }
}


private struct ProfileTabButton: View {
    let tab: ProfileTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                Rectangle()
                    .fill(isSelected ? Color.textPrimary : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileTabsView(selectedTab: .constant(.videos))
        .background(Color.backgroundLight)
}
