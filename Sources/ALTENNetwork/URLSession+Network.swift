//
//  URLSession+Network.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

extension URLSession {
    
    @available(iOS 15.0, *)
    public func requestData(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return NetworkDataResponse(try await self.data(for: request.asURLRequest(), delegate: delegate))
    }
    
    public func requestData(for request: URLRequestConvertible) async throws -> NetworkDataResponse {
        if #available(iOS 15, *) {
            return try await requestData(for: request, delegate: nil)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.dataTask(with: request.asURLRequest()) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse((data, response)))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }.resume()
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func requestDownload(for request: URLRequestConvertible, delegate: URLSessionTaskDelegate?) async throws -> NetworkDownloadResponse {
        return NetworkDownloadResponse(try await self.download(for: request.asURLRequest(), delegate: delegate))
    }
    
    public func requestDownload(for request: URLRequestConvertible) async throws -> NetworkDownloadResponse {
        if #available(iOS 15, *) {
            return try await requestDownload(for: request, delegate: nil)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.downloadTask(with: request.asURLRequest()) { url, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url, let response = response {
                        continuation.resume(returning: NetworkDownloadResponse((url, response)))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }.resume()
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return NetworkDataResponse(try await self.upload(for: request.asURLRequest(), from: bodyData, delegate: delegate))
    }
    
    public func requestUpload(for request: URLRequestConvertible, from bodyData: Data) async throws -> NetworkDataResponse {
        if #available(iOS 15, *) {
            return try await requestUpload(for: request, from: bodyData, delegate: nil)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.uploadTask(with: request.asURLRequest(), from: bodyData) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse((data, response)))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }.resume()
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, delegate: URLSessionTaskDelegate?) async throws -> NetworkDataResponse {
        return NetworkDataResponse(try await self.upload(for: request.asURLRequest(), fromFile: fileURL, delegate: delegate))
    }
    
    public func requestUpload(for request: URLRequestConvertible, fromFile fileURL: URL, from bodyData: Data) async throws -> NetworkDataResponse {
        if #available(iOS 15, *) {
            return try await requestUpload(for: request, fromFile: fileURL, delegate: nil)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.uploadTask(with: request.asURLRequest(), fromFile: fileURL) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        continuation.resume(returning: NetworkDataResponse((data, response)))
                    } else {
                        continuation.resume(throwing: NetworkError.unknown)
                    }
                    
                }.resume()
            }
        }
    }
}
