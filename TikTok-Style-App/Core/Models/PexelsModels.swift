//
//  PexelsModels.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation


struct PexelsVideoResponse: Decodable {
    let page: Int
    let perPage: Int
    let totalResults: Int
    let url: String?
    let videos: [PexelsVideo]
    let nextPage: String?
    let prevPage: String?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case totalResults = "total_results"
        case url
        case videos
        case nextPage = "next_page"
        case prevPage = "prev_page"
    }
}


struct PexelsVideo: Decodable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let duration: Int
    let user: PexelsUser
    let videoFiles: [PexelsVideoFile]
    let videoPictures: [PexelsVideoPicture]

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, image, duration, user
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
}


struct PexelsUser: Decodable {
    let id: Int
    let name: String
    let url: String
}


struct PexelsVideoFile: Decodable, Identifiable {
    let id: Int
    let quality: String?
    let fileType: String?
    let width: Int?
    let height: Int?
    let fps: Double?
    let link: String

    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, fps, link
        case fileType = "file_type"
    }
}


struct PexelsVideoPicture: Decodable, Identifiable {
    let id: Int
    let picture: String
    let nr: Int
}


extension PexelsVideo {

    // Convert to app's Video model
    func toDomainModel() -> Video {
        // Get the best quality video file (prefer HD)
        let videoFile = bestVideoFile

        return Video(
            id: id,
            user: VideoUser(
                id: user.id,
                name: user.name,
                username: user.name.lowercased().replacingOccurrences(of: " ", with: "_"),
                avatarURL: nil
            ),
            videoURL: URL(string: videoFile?.link ?? "")!,
            thumbnailURL: URL(string: image),
            likeCount: Int.random(in: 1000...100000),
            commentCount: Int.random(in: 100...5000),
            shareCount: Int.random(in: 50...2000),
            bookmarkCount: Int.random(in: 100...10000),
            caption: generateCaption(),
            musicTitle: "Original Sound - \(user.name)"
        )
    }

    //Get the best quality video file (prefer 720p or 1080p)
    private var bestVideoFile: PexelsVideoFile? {
        // Prefer HD quality for mobile
        let preferredQualities = ["hd", "sd", "hls"]

        for quality in preferredQualities {
            if let file = videoFiles.first(where: { $0.quality?.lowercased() == quality }) {
                return file
            }
        }

        return videoFiles.first
    }

    /// Generate a random caption
    private func generateCaption() -> String {
        let captions = [
            "Check out this amazing moment! #fyp #viral",
            "POV: When life gives you lemons 🍋 #relatable",
            "This is everything! ✨ #trending #foryou",
            "Wait for it... 👀 #surprise #mustwatch",
            "Making memories one video at a time 🎬 #content",
            "Can't stop watching this! #addictive #loop",
            "Tag someone who needs to see this 👇 #share",
            "The vibes are immaculate ✨ #mood #aesthetic"
        ]
        return captions.randomElement() ?? "#fyp #viral"
    }
}

// MARK: - Array Extension for Mapping
extension Array where Element == PexelsVideo {
    func toDomainModels() -> [Video] {
        map { $0.toDomainModel() }
    }
}
