//
//  ActionButton.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let activeIcon: String?
    let count: Int
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    init(
        icon: String,
        activeIcon: String? = nil,
        count: Int,
        isActive: Bool = false,
        activeColor: Color = .likePink,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.activeIcon = activeIcon
        self.count = count
        self.isActive = isActive
        self.activeColor = activeColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isActive ? (activeIcon ?? icon) : icon)
                    .font(.system(size: 28))
                    .foregroundColor(isActive ? activeColor : .white)
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)

                Text(count.formatted)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Number Formatting
extension Int {
    var formatted: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", Double(self) / 1_000)
        }
        return "\(self)"
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        HStack(spacing: 24) {
            ActionButton(
                icon: "heart",
                activeIcon: "heart.fill",
                count: 15700,
                isActive: false
            ) {}

            ActionButton(
                icon: "heart",
                activeIcon: "heart.fill",
                count: 15700,
                isActive: true
            ) {}

            ActionButton(
                icon: "ellipsis.bubble",
                count: 2414
            ) {}

            ActionButton(
                icon: "arrowshape.turn.up.right",
                count: 521
            ) {}
        }
    }
}
