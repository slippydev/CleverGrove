//
//  OpenAIChat.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-10-10.
//

import Foundation

/// Struct representing a message used in chat completions.
public struct AIMessage: Codable {
    enum AIMessageRole: String, Codable {
        case system
        case user
        case assistant
    }
    
    let role: AIMessageRole
    let content: String

    /// Initializes an AIMessage.
    /// - Parameters:
    ///   - role: The role of the message (system, user, or assistant).
    ///   - content: The content of the message.
    init(role: AIMessageRole, content: String) {
        self.role = role
        self.content = content
    }
}

/// Struct representing a response from chat completions.
struct ChatCompletionResponse: Codable, DecodableResponse {
    public struct Choice: Codable {
        public var text: String?
        public var message: AIMessage?
        public let index: Int
        public var logprobs: Int?
        public var finishReason: String?
    }

    struct Usage: Codable {
        public var promptTokens: Int?
        public var completionTokens: Int?
        public var totalTokens: Int?
    }

    struct Logprobs: Codable {
        public var tokens: [String]?
        public var tokenLogprobs: [Double]?
        public var topLogprobs: [String: Double]?
        public var textOffset: [Int]?
    }

    var id: String?
    let object: String
    let created: TimeInterval
    var model: String?
    let choices: [Choice]
    var usage: Usage?
    var logprobs: Logprobs?
    var message: AIMessage? { choices.first?.message }
    
    /// Decodes response data into a ChatCompletionResponse object.
    static func decode(data: Data) -> Codable? {
        let decoder = JSONDecoder.openAIDecoder
        let response = try? decoder.decode(ChatCompletionResponse.self, from: data)
        return response
    }
}

/// Struct representing a request for chat completions.
public struct ChatCompletionsRequest: Codable {
    let model: String
    let messages: [AIMessage]
    var temperature: Double? = nil
    var n: Int? = nil
    var maxTokens: Int? = nil
    var topP: Double? = nil
    var frequencyPenalty: Double? = nil
    var presencePenalty: Double? = nil
    var logprobs: Int? = nil
    var stop: [String]? = nil
    var user: String? = nil
    var stream: Bool = false
}

extension OpenAI {

    /**
     Sends a chat completion request to the OpenAI API.
     - Parameters:
     - newMessage: The new message to be added to the conversation.
     - previousMessages: An array of previous messages in the conversation.
     - maxTokens: The maximum number of tokens in the response.
     - temperature: A value controlling randomness (default is 1).
     - n: Number of completions to generate.
     - topP: An alternative to temperature for controlling randomness.
     - frequencyPenalty: A penalty to discourage overly repetitive responses.
     - presencePenalty: A penalty to discourage the use of certain tokens.
     - logprobs: Include log probabilities of each token.
     - stop: An array of strings at which the response should stop.
     - user: An optional user identifier.
     - Returns: A ChatCompletionResponse object.
     */
    func sendChatCompletion(newMessage: AIMessage,
                            previousMessages: [AIMessage] = [],
                            maxTokens: Int?,
                            temperature: Double = 1,
                            n: Int? = nil,
                            topP: Double? = nil,
                            frequencyPenalty: Double? = nil,
                            presencePenalty: Double? = nil,
                            logprobs: Int? = nil,
                            stop: [String]? = nil,
                            user: String? = nil) async throws -> ChatCompletionResponse
    {
        var messages = previousMessages
        messages.append(newMessage)

        let requestBody = ChatCompletionsRequest(model: info.chatModel,
                                                 messages: messages,
                                                 temperature: temperature,
                                                 n: n,
                                                 maxTokens: maxTokens,
                                                 topP: topP,
                                                 frequencyPenalty: frequencyPenalty,
                                                 presencePenalty: presencePenalty,
                                                 logprobs: logprobs,
                                                 stop: stop,
                                                 user: user)
        let jsonEncoder = JSONEncoder.openAIEncoder
        let requestData = try jsonEncoder.encode(requestBody)
        let result: ChatCompletionResponse = try await network.request(HTTPMethod.post,
                                                                       url: info.chatCompletionsPath,
                                                                       body: requestData,
                                                                       headers: baseHeaders)
        return result
    }
}
