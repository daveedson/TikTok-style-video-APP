//
//  AppColors.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

// MARK: - Gradient Definitions
extension LinearGradient {

    /// Orange to Yellow gradient - Used for create button (+)
    static let accentGradient = LinearGradient(
        colors: [Color.accentOrange, Color.accentYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Vertical fade for video overlay text readability
    static let videoOverlayGradient = LinearGradient(
        colors: [
            Color.clear,
            Color.black.opacity(0.3),
            Color.black.opacity(0.7)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Preview Helper
private struct AppColorRow: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Text(name)
                .font(.system(.body, design: .monospaced))

            Spacer()
        }
    }
}

#Preview("Color Palette") {
    ScrollView {
        VStack(spacing: 16) {
            AppColorRow(name: "Accent Orange", color: .accentOrange)
            AppColorRow(name: "Accent Yellow", color: .accentYellow)
            AppColorRow(name: "Like Pink", color: .likePink)

            Divider()

            AppColorRow(name: "Background Dark", color: .backgroundDark)
            AppColorRow(name: "Background Light", color: .backgroundLight)
            AppColorRow(name: "Overlay Background", color: .overlayBackground)
            AppColorRow(name: "Tab Bar Background", color: .tabBarBackground)

            Divider()

            AppColorRow(name: "Text Primary", color: .textPrimary)
            AppColorRow(name: "Text Secondary", color: .textSecondary)

            Divider()

            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient.accentGradient)
                .frame(height: 60)
                .overlay(
                    Text("Accent Gradient")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                )
        }
        .padding()
    }
}
