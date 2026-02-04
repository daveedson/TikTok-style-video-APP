//
//  VideoService.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation


protocol VideoServiceProtocol {
    func fetchVideos(query: String, page: Int, perPage: Int) async throws -> [Video]
}


final class VideoService: VideoServiceProtocol {

    static let shared = VideoService()

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

   
    func fetchVideos(
        query: String = APIConfiguration.defaultQuery,
        page: Int = 1,
        perPage: Int = APIConfiguration.perPage
    ) async throws -> [Video] {

        let endpoint = APIEndpoint.searchVideos(query: query, page: page, perPage: perPage)

        let response: PexelsVideoResponse = try await networkManager.request(
            url: endpoint.url,
            parameters: endpoint.parameters
        )

        return response.videos.toDomainModels()
    }
}
