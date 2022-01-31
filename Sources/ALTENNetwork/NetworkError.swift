//
//  NetworkError.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case request(NetworkRequestError)
    case response(NetworkResponseError)
    case unknown
}

public enum NetworkResponseError: Error {
    case invalidResponse(NetworkResponse)
    case invalidStatusCode(NetworkResponse, Int)
    case decodeError(Error)
}

public enum NetworkRequestError: Error {
    case invalidURL
    case encodeError(Error)
}
