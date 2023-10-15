//
//  OpenAI.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-10-10.
//

import Foundation

struct OpenAIInfo {
    let embeddingsPath = "https://api.openai.com/v1/embeddings"
    let chatCompletionsPath = "https://api.openai.com/v1/chat/completions"
    let embeddingsModel = "text-embedding-ada-002"
    let chatModel = "gpt-3.5-turbo"
}

enum LoggableAIEvent: String {
    case trainExpert = "train_expert"
    case chatExchange = "chat_exchange"
}

class OpenAI {
    let info = OpenAIInfo()
    let openAIKey: String
    let network: NetworkInterface
    let logger: Loggable?
    
    init(openAIKey: String, network: NetworkInterface, logger: Loggable? = nil) {
        self.openAIKey = openAIKey
        self.network = network
        self.logger = logger
    }
    
    var baseHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(openAIKey)"
        headers["content-type"] = "application/json"
        return headers
    }
}
