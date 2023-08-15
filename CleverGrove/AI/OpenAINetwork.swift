//
//  OpenAINetwork.swift
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

enum OpenAIError: Error {
    case invalidRequest(String)
    case invalidURL
    case invalidResponse
    case badStatus(String)
    case jsonDecodingError
    case cancelled
}

struct OpenAINetwork {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func request<T: DecodableResponse & Codable>(_ method: HTTPMethod, url: String, body: Data?, headers: [String: String]) async -> Result<T, OpenAIError>  {
        guard let url = URL(string: url) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            guard 200 ... 299 ~= response.statusCode else {
                var userInfo: [String: Any] = [:]

                if let decodedError = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    userInfo = decodedError
                }

                let error = NSError(domain: NSURLErrorDomain, code: response.statusCode, userInfo: userInfo)
                return .failure(.badStatus(error.localizedDescription))
            }

            guard let responseObj = T.decode(data: data) as? T else {
                return .failure(.jsonDecodingError)
            }
            return .success(responseObj)
        } catch {
            return .failure(.invalidRequest(error.localizedDescription))
        }
    }
}
