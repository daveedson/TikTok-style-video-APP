//
//  NetworkManager.swift
//  TikTok-Style-App
//
//  Created by DavidOnoh on 2/1/26.
//

import Foundation
import Alamofire


final class NetworkManager {

    static let shared = NetworkManager()

    private let session: Session
    private let decoder: JSONDecoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = Session(configuration: configuration)

        self.decoder = JSONDecoder()
    }

 
    func request<T: Decodable>(
        url: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil
    ) async throws -> T {

        print("API Request \(method.rawValue) \(url)")
        if let parameters = parameters {
            print("API Params \(parameters)")
        }

        let headers: HTTPHeaders = [
            "Authorization": APIConfiguration.apiKey
        ]

        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self, decoder: decoder) { response in
                if let data = response.data, let rawString = String(data: data, encoding: .utf8) {
                    print("API Raw Response \(rawString.prefix(500))...")
                }

                switch response.result {
                case .success(let value):
                    print("API Success \(url)")
                    if let videoResponse = value as? PexelsVideoResponse {
                        print("API Data Page: \(videoResponse.page), Videos: \(videoResponse.videos.count), Total: \(videoResponse.totalResults)")
                    }
                    continuation.resume(returning: value)
                case .failure(let error):
                    print("API Error \(url)")
                    print("API Error Details \(error.localizedDescription)")
                    if let statusCode = response.response?.statusCode {
                        print("API Status Code \(statusCode)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
