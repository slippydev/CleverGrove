//
//  OpenAIEmbeddings.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation

/// Struct representing a request for text embeddings.
struct EmbeddingsRequest: Codable {
    public let model: String
    public let input: String
}

/// Struct representing a response from text embeddings.
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
    
    /**
     Get Text Embeddings for a Single Input
     Sends a request to OpenAI's API to obtain text embeddings for a single input string.
     
     - Parameters:
     - input: The text input for which embeddings are requested.
     
     - Returns: An `EmbeddingsResponse` containing the embedded data.
     
     - Throws: An error if the request fails or if the response cannot be decoded.
     
     - SeeAlso: `getEmbeddings(input chunks:)` for batch processing.
     */
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
    
    /**
     Get Text Embeddings for Multiple Input Chunks
     
     Sends a request to OpenAI's API to obtain text embeddings for multiple input chunks and returns a dictionary of embeddings.
     
     - Parameters:
     - chunks: An array of input text chunks for which embeddings are requested.
     
     - Returns: A dictionary where the key is the index of the chunk and the value is the corresponding embedding.
     
     - Throws: An error if the request for any chunk fails or if the responses cannot be decoded.
     
     - Note: This function sends requests in parallel for each chunk to improve efficiency.
     
     - SeeAlso: `getEmbeddings(input:)` for a single input.
     */
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

