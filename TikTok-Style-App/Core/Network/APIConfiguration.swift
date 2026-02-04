//
//  APIConfiguration.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation

enum APIConfiguration {
    static let baseURL = "https://api.pexels.com"
    static let apiKey = Keys.pexelsAPIKey

    static let defaultQuery = "people"
    static let perPage = 80
}

enum APIEndpoint {
    case searchVideos(query: String, page: Int, perPage: Int)

    var url: String {
        switch self {
        case .searchVideos:
            return "\(APIConfiguration.baseURL)/videos/search"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .searchVideos(let query, let page, let perPage):
            return [
                "query": query,
                "page": page,
                "per_page": perPage
            ]
        }
    }
}
