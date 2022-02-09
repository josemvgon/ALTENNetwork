//
//  NetworkDataResponse.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

public struct NetworkDataResponse {
    let data: Data
    let response: URLResponse
    
    init(_ dataResponse: (Data, URLResponse)) {
        data = dataResponse.0
        response = dataResponse.1
    }
}

extension NetworkDataResponse {
    public func jsonDecode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.responseData(.decodeError(error))
        }
    }
}

extension NetworkDataResponse {
    public func validate(correctRange range: HTTPCodes = .success) throws -> Self {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseData(.invalidResponse(self))
        }
        guard range ~= response.statusCode else {
            throw NetworkError.responseData(.invalidStatusCode(self, response.statusCode))
        }
        return self
    }
}
