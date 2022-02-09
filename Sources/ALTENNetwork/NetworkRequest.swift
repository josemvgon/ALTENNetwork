//
//  NetworkRequest.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

open class NetworkRequest {
    public let urlRequest: URLRequest
    
    public init(url: URL,
                httpMethod: NetworkHttpMethod = .get,
                headers: [NetworkHeader]? = nil,
                query: [NetworkQuery]? = nil,
                httpBody: Data? = nil) throws {
        
        guard var components = URLComponents(string: url.absoluteString) else { throw NetworkError.request(.invalidURL) }
        if let query = query {
            components.queryItems = (components.queryItems ?? []) + query.map { $0.asURLQueryItem() }
        }
        guard let url = components.url else { throw NetworkError.request(.invalidURL) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers?.reduce(into: [:], { (result, item) in result[item.key] = item.value })
        urlRequest.httpBody = httpBody
        
        self.urlRequest = urlRequest
    }
    
    public convenience init(url: String,
                            httpMethod: NetworkHttpMethod = .get,
                            headers: [NetworkHeader]? = nil,
                            query: [NetworkQuery]? = nil,
                            httpBody: Data? = nil) throws {
        guard let url = URL(string: url) else { throw NetworkError.request(.invalidURL) }
        try self.init(url: url, httpMethod: httpMethod, headers: headers, query: query, httpBody: httpBody)
    }
    
    public convenience init<T: Encodable>(url: URL,
                                          httpMethod: NetworkHttpMethod,
                                          headers: [NetworkHeader]? = nil,
                                          query: [NetworkQuery]? = nil,
                                          jsonBody: T? = nil,
                                          encoder: JSONEncoder = JSONEncoder()) throws {
        var httpBodyData: Data?
        if let jsonBody = jsonBody {
            do {
                httpBodyData = try encoder.encode(jsonBody)
            } catch {
                throw NetworkError.request(.encodeError(error))
            }
        }
        try self.init(url: url, httpMethod: httpMethod, headers: [NetworkHeader(key: "Content-Type", value: "application/json")] + (headers ?? []), query: query, httpBody: httpBodyData)
    }
    
    public convenience init<T: Encodable>(url: String,
                                          httpMethod: NetworkHttpMethod,
                                          headers: [NetworkHeader]? = nil,
                                          query: [NetworkQuery]? = nil,
                                          jsonBody: T? = nil,
                                          encoder: JSONEncoder = JSONEncoder()) throws {
        guard let url = URL(string: url) else { throw NetworkError.request(.invalidURL) }
        try self.init(url: url, httpMethod: httpMethod, headers: headers, query: query, jsonBody: jsonBody)
    }
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
}

extension NetworkRequest: URLRequestConvertible {
    public func asURLRequest() -> URLRequest {
        return urlRequest
    }
}

