//
//  URLRequestConvertible.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

public protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest
}

extension URL: URLRequestConvertible {
    public func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() -> URLRequest {
        return self
    }
}
