//
//  NetworkUtilities.swift
//  Rafita_app
//
//  Created by Rafael FERNANDEZ on 17/1/22.
//  Copyright © 2022 company_app. All rights reserved.
//

import Foundation

public final class NativeSwiftClass {
    public init() { }
    
    dynamic public func original() {
        print("original")
    }
}

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    public static let success = 200 ..< 300
}

public struct NetworkHeader {
    public let key: String
    public let value: String
    
    public static func header(key: String, value: String) -> Self { NetworkHeader(key: key, value: value) }
}

public struct NetworkQuery {
    public let key: String
    public let value: String
    private let allowEncodingValue: Bool
    
    public static func query(key: String, value: String, allowEncodingValue: Bool = true) -> Self { NetworkQuery(key: key, value: value, allowEncodingValue: allowEncodingValue) }
    
    public func asURLQueryItem() -> URLQueryItem {
        URLQueryItem(name: key, value: (allowEncodingValue) ? value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) : value)
    }
}

public struct NetworkHttpMethod: RawRepresentable {
    public let rawValue: String
    
    public static let get = NetworkHttpMethod(rawValue: "GET")
    public static let post = NetworkHttpMethod(rawValue: "POST")
    public static let put = NetworkHttpMethod(rawValue: "PUT")
    public static let delete = NetworkHttpMethod(rawValue: "DELETE")
    public static let head = NetworkHttpMethod(rawValue: "HEAD")
    public static let patch = NetworkHttpMethod(rawValue: "PATCH")
    public static func other(_ method: String) -> NetworkHttpMethod { NetworkHttpMethod(rawValue: method) }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
