//
//  URLSession+Network.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

extension URLSession {
    public func doRequest(for request: URLRequestConvertible) async throws -> NetworkResponse {
        if #available(iOS 15, *) {
            return NetworkResponse(try await URLSession.shared.data(for: request.asURLRequest()))
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: request.asURLRequest()) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkResponse((data, response)))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }.resume()
            }
        }
    }
}
