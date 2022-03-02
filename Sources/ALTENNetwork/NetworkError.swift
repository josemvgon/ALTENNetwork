//
//  NetworkError.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Tipo de error general que pueden producirse. La librería podrá devolver estos tipos de error o errores producidos por `URLSession`
public enum NetworkError: Error {
    /// Error producido durante la petición
    case request(Request)
    /// Error producido durante el tratamiento de la respuesta
    case responseData(DataResponse)
    /// Error producido durante el tratamiento de la respuesta de peticiones de tipo download
    case responseDownload(DownloadResponse)
    /// Error desconocido
    case unknown
}

extension NetworkError {
    /// Tipo de error producido en el tratamiento de los datos de respuesta de una petición
    public enum DataResponse: Error {
        /// Error que indica que el `URLResponse` no es válido
        case invalidResponse(NetworkDataResponse)
        /// Error que indica que el `statusCode` del `HTTPURLResponse` no es válido
        case invalidStatusCode(NetworkDataResponse, Int)
        /// Error que indica que ha ocurrido un fallo durante la decodificación del `data` de `NetworkDataResponse`
        case decodeError(Error)
    }
}

extension NetworkError {
    /// Tipo de error producido en el tratamiento de los datos de respuesta de una petición
    public enum DownloadResponse: Error {
        /// Error que indica que el `URLResponse` no es válido
        case invalidResponse(NetworkDownloadResponse)
        /// Error que indica que el `statusCode` del `HTTPURLResponse` no es válido
        case invalidStatusCode(NetworkDownloadResponse, Int)
    }
}

extension NetworkError {
    /// Tipo de error producido durante la creación de la petición
    public enum Request: Error {
        /// Error que indica que la url de la petición no tiene un formato correcto
        case invalidURL
        /// Error que indica que no puede transformar el objeto `Encodable` a `json`
        case encodeError(Error)
    }
}

extension NetworkError {
    /// Errores producidos durante el uso de `NetworkReachability`
    public enum Reachability: Error {
        case failedToCreateWithAddress(sockaddr, Int32)
        case failedToCreateWithHostname(String, Int32)
        case unableToSetCallback(Int32)
        case unableToSetDispatchQueue(Int32)
        case unableToGetFlags(Int32)
        case alreadyRunning
    }
}
