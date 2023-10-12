//
//  OpenAIChat.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-10-10.
//

import Foundation

public struct AIMessage: Codable {
    enum AIMessageRole: String, Codable {
        case system
        case user
        case assistant
    }
    
    let role: AIMessageRole
    let content: String

    init(role: AIMessageRole, content: String) {
        self.role = role
        self.content = content
    }
}

struct ChatCompletionResponse: Codable, DecodableResponse {
    public struct Choice: Codable {
        public var text: String? = nil
        public let index: Int
        public var logprobs: Int? = nil
        public var finishReason: String? = nil
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
    
    static func decode(data: Data) -> Codable? {
        let decoder = JSONDecoder.openAIDecoder
        let response = try? decoder.decode(ChatCompletionResponse.self, from: data)
        return response
    }
}

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
    /// Creates a completion for the chat message
    ///
    /// - Parameters:
    ///   - newMessage: The main input is the `newMessage` parameter. Where each object has a `role` (either `system`, `user`, or `assistant`) and `content` (the content of the message).
    ///   - previousMessages: Previous messages, an optional parameter, the assistant will communicate in the context of these messages. Must be an array of `AIMessage` objects.
    ///   - model: ID of the model to use.
    ///   - maxTokens: The maximum number of tokens to generate in the completion.
    ///   - temperature: What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or `topP` but not both.
    ///   - n: How many completions to generate for each prompt.
    ///   - topP: An alternative to sampling with `temperature`, called nucleus sampling, where the model considers the results of the tokens with `topP` probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or `temperature` but not both.
    ///   - frequencyPenalty: Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    ///   - presencePenalty: Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    ///   - logprobs: Include the log probabilities on the `logprobs` most likely tokens, as well the chosen tokens. For example, if `logprobs` is 5, the API will return a list of the 5 most likely tokens. The API will always return the `logprob` of the sampled token, so there may be up to `logprobs+1` elements in the response. The maximum value for `logprobs` is 5.
    ///   - stop: Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    ///   - user: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
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
        let network = OpenAINetwork()
        let result: ChatCompletionResponse = try await network.request(info.method, 
                                                                       url: info.embeddingsPath,
                                                                       body: requestData,
                                                                       headers: baseHeaders)
        return result
    }
}
