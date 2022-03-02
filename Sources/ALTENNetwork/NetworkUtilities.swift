//
//  NetworkUtilities.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Alias el tratamiento de los `statusCode` de un `HTTPURLResponse`
public typealias HTTPCode = Int
/// Alias para englobar un rango de `HTTPCode`
public typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    /// Rango de códigos que "por defecto" indican que una petición es correcta
    public static let success = 200 ..< 300
}

/// Tipo de dato que normaliza la creación de cabeceras http
public struct NetworkHeader {
    /// Clave de la cabecera http
    public let key: String
    /// Valor de la cabecera http
    public let value: String
    
    /// Crea un nuevo `NetworkHeader`
    /// - Parameters:
    ///   - key: Clave de la cabecera http
    ///   - value: Valor de la cabecera http
    /// - Returns: instancia de `NetworkHeader`
    public static func header(key: String, value: String) -> Self { NetworkHeader(key: key, value: value) }
}

/// Tipo de dato que normaliza la creación de parámetros de tipo `query` de una petición
public struct NetworkQuery {
    /// Clave del parámetro
    public let key: String
    /// Valor del parámetro
    public let value: String
    /// Indica si debe codificar el valor para la eliminación de caracteres extraños con el uso de la función `value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`
    private let allowEncodingValue: Bool
    
    /// Crea un nuevo `NetworkRequest`
    /// - Parameters:
    ///   - key: Clave del parámetro
    ///   - value: Valor del parámetro
    ///   - allowEncodingValue: Indica si debe codificar el valor para la eliminación de caracteres extraños con el uso de la función `value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`
    /// - Returns: instancia de `NetworkRequest`
    public static func query(key: String, value: String, allowEncodingValue: Bool = true) -> Self { NetworkQuery(key: key, value: value, allowEncodingValue: allowEncodingValue) }
    
    /// Transforma el objeto al tipo nativo `URLQueryItem`
    /// - Returns: instancia de `URLQueryItem`
    public func asURLQueryItem() -> URLQueryItem {
        URLQueryItem(name: key, value: (allowEncodingValue) ? value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) : value)
    }
}

/// Tipos de métodos http de las peticiones
public struct NetworkHttpMethod: RawRepresentable {
    public let rawValue: String
    
    public static let get = NetworkHttpMethod(rawValue: "GET")
    public static let head = NetworkHttpMethod(rawValue: "HEAD")
    public static let post = NetworkHttpMethod(rawValue: "POST")
    public static let put = NetworkHttpMethod(rawValue: "PUT")
    public static let delete = NetworkHttpMethod(rawValue: "DELETE")
    public static let trace = NetworkHttpMethod(rawValue: "TRACE")
    public static let options = NetworkHttpMethod(rawValue: "OPTIONS")
    public static let connect = NetworkHttpMethod(rawValue: "CONNECT")
    public static let patch = NetworkHttpMethod(rawValue: "PATCH")
    public static let move = NetworkHttpMethod(rawValue: "MOVE")
    public static func other(_ method: String) -> NetworkHttpMethod { NetworkHttpMethod(rawValue: method) }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
