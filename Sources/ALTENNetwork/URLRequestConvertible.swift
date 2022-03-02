//
//  URLRequestConvertible.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/**
 Protocolo que permite convertir cualquier tipo de dato a un tipo `URLRequest`. Es usado por los nuevos métodos de `URLSession` para la conexión a internet.
 
 Lo conforman `URL`, `URLSession` y `NetworkRequest`
 */
public protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest
}

extension URL: URLRequestConvertible {
    /// Convierte el objeto al tipo `URLRequest`
    /// - Returns: url de la petición
    public func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}

extension URLRequest: URLRequestConvertible {
    /// Convierte el objeto al tipo `URLRequest`
    /// - Returns: url de la petición
    public func asURLRequest() -> URLRequest {
        return self
    }
}
