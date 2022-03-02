//
//  NetworkDataResponse.swift
//
//  Copyright © 2022 ALTEN. All rights reserved.
//

import Foundation

/// Tipo de dato que normaliza las respuestas de una petición con `URLSession`
public struct NetworkDataResponse {
    /// Datos devueltos por la petición
    public let data: Data
    /// Response de la petición
    public let response: URLResponse
    
    /// Crea una instancia de `NetworkDownloadResponse`
    /// - Parameter dataResponse: Tupla con los valores devueltos por la petitición
    public init(_ dataResponse: (Data, URLResponse)) {
        data = dataResponse.0
        response = dataResponse.1
    }
}

extension NetworkDataResponse {
    /// Transforma el `data` del objeto al tipo `Decodable` indicado. `data` deberá ser un `json`
    /// - Parameters:
    ///   - type: tipo de objeto al que se debe trasnformar
    ///   - decoder: instancia de `JSONEncoder` usado para transformar el parámetro `data` a `T`
    /// - Returns: instancia del nuevo tipo de objeto `T`
    public func jsonDecode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.responseData(.decodeError(error))
        }
    }
}

extension NetworkDataResponse {
    /// Valida el `statusCode` de la petición en base a los rangos aceptados
    /// - Parameter range: rango de códigos aceptados
    /// - Returns: la misma instancia de `NetworkDownloadResponse`
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
