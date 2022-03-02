//
//  NetworkDownloadResponse.swift
//  
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Tipo de dato que normaliza las respuestas de una petición de descarga con `URLSession`
public struct NetworkDownloadResponse {
    /// Ruta del fichero descargado a través de la petición
    public let url: URL
    /// Response de la petición
    public let response: URLResponse
    
    /// Crea una instancia de `NetworkDownloadResponse`
    /// - Parameter dataResponse: Tupla con los valores devueltos por la petitición
    public init(_ dataResponse: (URL, URLResponse)) {
        url = dataResponse.0
        response = dataResponse.1
    }
}


extension NetworkDownloadResponse {
    /// Valida el `statusCode` de la petición en base a los rangos aceptados
    /// - Parameter range: rango de códigos aceptados
    /// - Returns: la misma instancia de `NetworkDownloadResponse`
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
