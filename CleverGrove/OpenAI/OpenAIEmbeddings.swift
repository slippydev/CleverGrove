//
//  OpenAIEmbeddings.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation
import SwiftUI

struct EmbeddingsRequest: Codable {
    public let model: String
    public let input: String
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
    
    static func decode(data: Data) -> Codable? {
        let decoder = JSONDecoder.openAIDecoder
        let response = try? decoder.decode(EmbeddingsResponse.self, from: data)
        return response
    }
}

extension OpenAI {
    
    func getEmbeddings(input: String) async throws -> EmbeddingsResponse
    {
        let jsonEncoder = JSONEncoder.openAIEncoder
        let requestBody = EmbeddingsRequest(model: info.embeddingsModel, input: input)
        let requestData = try jsonEncoder.encode(requestBody)
        let result: EmbeddingsResponse = try await network.request(HTTPMethod.post,
                                                                   url: info.embeddingsPath,
                                                                   body: requestData,
                                                                   headers: baseHeaders)
        return result
    }
    
    func getEmbeddings(input chunks: [String]) async throws -> [Int: [Double]] {
        var embeddings = [Int: [Double]]()
        var tokenUsage: Int = 0
        try await withThrowingTaskGroup(of: (Int, [Double]?, Int?).self) { group in
            for (i, chunk) in chunks.enumerated() {
                group.addTask { [weak self] in
                    let response = try await self?.getEmbeddings(input: chunk)
                    return (i, response?.embedding, response?.usage.totalTokens)
                }
            }
            // Obtain results from the child tasks, sequentially, in order of completion.
            for try await (index, embedding, tokens) in group {
                embeddings[index] = embedding
                tokenUsage += tokens ?? 0
            }
        }
        logger?.log(LoggableAIEvent.trainExpert.rawValue, params: [AnalyticsParams.tokenCount.rawValue: tokenUsage])
        return embeddings
    }
}

