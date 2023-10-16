//
//  OpenAI.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-10-10.
//

import Foundation

/// Struct holding information about OpenAI API endpoints and models.
struct OpenAIInfo {
    let embeddingsPath = "https://api.openai.com/v1/embeddings"
    let chatCompletionsPath = "https://api.openai.com/v1/chat/completions"
    let embeddingsModel = "text-embedding-ada-002"
    let chatModel = "gpt-3.5-turbo"
}

/// Enum representing various AI-related events to log.
enum LoggableAIEvent: String {
    case trainExpert = "train_expert"
    case chatExchange = "chat_exchange"
}

/// Class for interacting with OpenAI APIs.
class OpenAI {
    let info = OpenAIInfo()
    let openAIKey: String
    let network: NetworkInterface
    let logger: Loggable?
    
    /// Initializes the OpenAI class.
    /// - Parameters:
    ///   - openAIKey: The API key for authentication.
    ///   - network: An object conforming to the NetworkInterface protocol for making network requests.
    ///   - logger: An optional logger for event logging (used for analytics).
    init(openAIKey: String, network: NetworkInterface, logger: Loggable? = nil) {
        self.openAIKey = openAIKey
        self.network = network
        self.logger = logger
    }
    
    /// Computed property that returns the base HTTP headers for API requests.
    var baseHeaders: [String: String] {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(openAIKey)"
        headers["content-type"] = "application/json"
        return headers
    }
}
