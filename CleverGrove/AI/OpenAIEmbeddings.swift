//
//  OpenAIEmbeddings.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation
import OpenAIKit
import SwiftUI

struct EmbeddingsInfo {
    let path = "https://api.openai.com/v1/embeddings"
    let method = HTTPMethod.post
    let model = "text-embedding-ada-002"
    let openAIKey = KeyStore.key(from: .openAI)
}

struct EmbeddingsRequest: Codable {
    public let model: String
    public let input: String
}

protocol DecodableResponse {
    static func decode(data: Data) -> EmbeddingsResponse?
}

struct EmbeddingsResponse: Codable, DecodableResponse {
    struct EmbeddingsData: Codable {
        public let object: String
        public let embedding: [Double]
        public let index: Int
    }

    struct EmbeddingsUsage: Codable {
        public let promptTokens: Int
        public let totalTokens: Int
    }
    
    public let object: String
    public let data: [EmbeddingsData]
    public let model: String
    public let usage: EmbeddingsUsage
    
    public var embedding: [Double]? {
        return data.first?.embedding
    }
    
    public var index: Int? {
        return data.first?.index
    }
    
    static func decode(data: Data) -> EmbeddingsResponse? {
        let decoder = JSONDecoder.openAIDecoder
        let response = try? decoder.decode(EmbeddingsResponse.self, from: data)
        return response
    }
    
}

class OpenAI {
    let info = EmbeddingsInfo()
    
    var baseHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(info.openAIKey.api_key)"
        headers["content-type"] = "application/json"
        return headers
    }
    
    func getEmbeddings(input: String) async throws -> EmbeddingsResponse
    {
        let jsonEncoder = JSONEncoder.openAIEncoder
        let requestBody = EmbeddingsRequest(model: info.model, input: input)
        let requestData = try jsonEncoder.encode(requestBody)
        let network = OpenAINetwork()
        let result: EmbeddingsResponse = try await network.request(info.method, url: info.path, body: requestData, headers: baseHeaders)
        return result
    }
    
    func getEmbeddings(input chunks: [String], progressHandler: @escaping (Double) -> Void) async throws -> [Int: [Double]] {
        var embeddings = [Int: [Double]]()
        for (i, chunk) in chunks.enumerated() {
            // FIXME: use Task Groups to optimize this to get embeddings for multiple chunks simultaneously
            let response = try await getEmbeddings(input: chunk)
            progressHandler(Double(i) / Double(chunks.count))
            if let embedding = response.embedding {
                embeddings[i] = embedding
            }
        }
        return embeddings
    }
}






