//
//  OpenAI.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-10-10.
//

import Foundation

struct OpenAIInfo {
    let embeddingsPath = "https://api.openai.com/v1/embeddings"
    let method = HTTPMethod.post
    let embeddingsModel = "text-embedding-ada-002"
    let chatModel = "gpt-3.5-turbo"
    let openAIKey = KeyStore.key(from: .openAI)
}


class OpenAI {
    let info = OpenAIInfo()
    let openAIKey: String
    
    init(openAIKey: String) {
        self.openAIKey = openAIKey
    }
    
    var baseHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(info.openAIKey.api_key)"
        headers["content-type"] = "application/json"
        return headers
    }
}
