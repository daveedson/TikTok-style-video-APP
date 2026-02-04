//
//  VideoOverlayView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct VideoOverlayView: View {
    let video: Video
    var onUsernameTap: () -> Void = {}
    var onFollowTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
          
            HStack(spacing: 12) {
                Button(action: onUsernameTap) {
                    Text(video.user.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                Button(action: onFollowTap) {
                    Text("Follow")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }

            if let caption = video.caption {
                Text(caption)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }

            if let musicTitle = video.musicTitle {
                MusicInfoView(
                    avatarURL: video.user.avatarURL,
                    musicTitle: musicTitle
                )
            }
        }
    }
}

// MARK: - Music Info View
struct MusicInfoView: View {
    let avatarURL: URL?
    let musicTitle: String

    var body: some View {
        HStack(spacing: 8) {
            
            Circle()
                .fill(Color.accentOrange)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("D")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.accentOrange, lineWidth: 2)
                        .padding(-2)
                )

           
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.system(size: 12))
                    .foregroundColor(.white)

                Text(musicTitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16)

            Spacer()
            RotatingDiscView()
        }
    }
}

// MARK: - Rotating Disc View
struct RotatingDiscView: View {
    @State private var isRotating = false

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.accentOrange, Color.accentYellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 36, height: 36)
            .overlay(
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
            )
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

