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
    case responseData(NetworkDataResponseError)
    case responseDownload(NetworkDownloadResponseError)
    case unknown
}

public enum NetworkDataResponseError: Error {
    case invalidResponse(NetworkDataResponse)
    case invalidStatusCode(NetworkDataResponse, Int)
    case decodeError(Error)
}

public enum NetworkDownloadResponseError: Error {
    case invalidResponse(NetworkDownloadResponse)
    case invalidStatusCode(NetworkDownloadResponse, Int)
}

public enum NetworkRequestError: Error {
    case invalidURL
    case encodeError(Error)
}


public enum NetworkReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr, Int32)
    case failedToCreateWithHostname(String, Int32)
    case unableToSetCallback(Int32)
    case unableToSetDispatchQueue(Int32)
    case unableToGetFlags(Int32)
    case alreadyRunning
}
