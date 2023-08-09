//
//  OpenAIEmbeddings.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation
import OpenAIKit

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
    
    static func decode(data: Data) -> EmbeddingsResponse? {
        let decoder = JSONDecoder.openAIDecoder
        let response = try? decoder.decode(EmbeddingsResponse.self, from: data)
        return response
    }
    
}

struct OpenAI {
    var baseHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(openAIKey.api_key)"
        headers["content-type"] = "application/json"
        return headers
    }
    
    func getEmbeddings(input: String) async -> Result<EmbeddingsResponse, OpenAIError>
    {
        let info = EmbeddingsInfo()
        let jsonEncoder = JSONEncoder.openAIEncoder
        let requestBody = EmbeddingsRequest(model: info.model, input: input)
        let requestData = try? jsonEncoder.encode(requestBody)
        let network = OpenAINetwork()
        let result: Result<EmbeddingsResponse, OpenAIError> = await network.request(info.method, url: info.path, body: requestData, headers: baseHeaders)
        return result
    }
}






