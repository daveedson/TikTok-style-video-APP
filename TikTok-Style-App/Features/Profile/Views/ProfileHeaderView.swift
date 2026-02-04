//
//  ProfileHeaderView.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    let profile: UserProfile
    var likesCount: Int = 0
    var onEditProfile: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {

            AvatarWithBadge(
                avatarURL: profile.avatarURL,
                badge: profile.badge
            )
            VStack(spacing: 8) {
                Text(profile.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text(profile.bio)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            StatsRow(
                videoCount: profile.videoCount,
                likesCount: likesCount,
                followerCount: profile.followerCount,
                followingCount: profile.followingCount
            )


            ActionButtonsRow(
                isCurrentUser: profile.isCurrentUser,
                onEditProfile: onEditProfile
            )
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Avatar with Badge
private struct AvatarWithBadge: View {
    let avatarURL: URL?
    let badge: String?

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                )
            if let badge = badge {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.accentOrange)
                .cornerRadius(12)
                .offset(y: -8)
            }
        }
    }
}

// MARK: - Stats Row
private struct StatsRow: View {
    let videoCount: Int
    let likesCount: Int
    let followerCount: Int
    let followingCount: Int

    var body: some View {
        HStack(spacing: 24) {
            StatItem(value: videoCount, label: "Videos")
            StatItem(value: likesCount, label: "Likes")
            StatItem(value: followerCount, label: "Followers")
            StatItem(value: followingCount, label: "Following")
        }
        .padding(.top, 8)
    }
}

private struct StatItem: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value.formattedCompact)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Number Formatting
extension Int {
    var formattedCompact: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", Double(self) / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", Double(self) / 1_000)
        }
        return "\(self)"
    }
}

// MARK: - Action Buttons Row
private struct ActionButtonsRow: View {
    let isCurrentUser: Bool
    var onEditProfile: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onEditProfile) {
                Text(isCurrentUser ? "Edit Profile" : "Follow")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.backgroundLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            IconActionButton(icon: "calendar")

            IconActionButton(icon: "chart.line.uptrend.xyaxis")
        }
        .padding(.top, 8)
    }
}

private struct IconActionButton: View {
    let icon: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
                .frame(width: 44, height: 44)
                .background(Color.backgroundLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileHeaderView(profile: .default, likesCount: 0)
        .background(Color.backgroundLight)
}
