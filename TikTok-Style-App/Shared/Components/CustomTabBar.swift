//
//  CustomTabBar.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case search
    case create
    case shop
    case profile

    var icon: String {
        switch self {
        case .home: return "flame"
        case .search: return "magnifyingglass"
        case .create: return "plus"
        case .shop: return "bag"
        case .profile: return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "flame.fill"
        case .search: return "magnifyingglass"
        case .create: return "plus"
        case .shop: return "bag.fill"
        case .profile: return "person.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let isDarkMode: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                if tab == .create {
                    CreateButton {
                        selectedTab = tab
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        isDarkMode: isDarkMode
                    ) {
                        selectedTab = tab
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            isDarkMode
                ? Color.tabBarBackground
                : Color.backgroundLight
        )
    }
}

// MARK: - Tab Bar Button
private struct TabBarButton: View {
    let tab: MainTab
    let isSelected: Bool
    let isDarkMode: Bool
    let action: () -> Void

    var iconColor: Color {
        if isSelected {
            return isDarkMode ? .accentOrange : .accentOrange
        }
        return isDarkMode ? .white.opacity(0.6) : .gray
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create Button (+ with gradient)
private struct CreateButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient.accentGradient)
                    .frame(width: 44, height: 32)

                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview("Dark Mode Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home), isDarkMode: true)
    }
    .background(Color.black)
}

#Preview("Light Mode Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.profile), isDarkMode: false)
    }
    .background(Color.white)
}
