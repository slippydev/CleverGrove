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
    
    func getEmbeddings(input chunks: [String]) async throws -> [Int: [Double]] {
        var embeddings = [Int: [Double]]()
        try await withThrowingTaskGroup(of: (Int, [Double]?).self) { group in
            for (i, chunk) in chunks.enumerated() {
                group.addTask { [weak self] in
                    let response = try await self?.getEmbeddings(input: chunk)
                    return (i, response?.embedding)
                }
            }
            // Obtain results from the child tasks, sequentially, in order of completion.
            for try await (index, embedding) in group {
                embeddings[index] = embedding
            }
        }
        return embeddings
    }
}

