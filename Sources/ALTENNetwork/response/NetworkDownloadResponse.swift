//
//  NetworkDownloadResponse.swift
//  
//
//  Created by Rafael FERNANDEZ on 31/1/22.
//

import Foundation

public struct NetworkDownloadResponse {
    let url: URL
    let response: URLResponse
    
    init(_ dataResponse: (URL, URLResponse)) {
        url = dataResponse.0
        response = dataResponse.1
    }
}


extension NetworkDownloadResponse {
    public func validate(correctRange range: HTTPCodes = .success) throws -> Self {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseDownload(.invalidResponse(self))
        }
        guard range ~= response.statusCode else {
            throw NetworkError.responseDownload(.invalidStatusCode(self, response.statusCode))
        }
        return self
    }
}
