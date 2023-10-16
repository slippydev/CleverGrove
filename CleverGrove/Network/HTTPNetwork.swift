//
//  HTTPNetwork.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case trace = "TRACE"
}

enum HTTPError: Error {
    case invalidRequest(String)
    case invalidURL
    case invalidResponse
    case badStatus(String)
    case jsonDecodingError
    case cancelled
}

protocol DecodableResponse {
    static func decode(data: Data) -> Codable?
}

protocol NetworkInterface {
    func request<T: DecodableResponse & Codable>(_ method: HTTPMethod, url: String, body: Data?, headers: [String: String]) async throws -> T
}

struct HTTPNetwork: NetworkInterface {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: DecodableResponse & Codable>(_ method: HTTPMethod, url: String, body: Data?, headers: [String: String]) async throws -> T  {
        guard let url = URL(string: url) else { throw HTTPError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        guard 200 ... 299 ~= response.statusCode else {
            throw HTTPError.badStatus("\(response.statusCode)")
        }
        guard let responseObj = T.decode(data: data) as? T else {
            throw HTTPError.jsonDecodingError
        }
        return responseObj
    }
}
