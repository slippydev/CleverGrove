//
//  PromptBuilder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-17.
//

import Foundation
import OpenAIKit

struct PromptBuilder {
    
    func context(relevantChunks: [CDTextChunk], expert: CDExpert) -> [AIMessage] {
        var aiMessages = [AIMessage]()
        aiMessages.append(instructions(expert: expert, relevantChunks: relevantChunks))
        aiMessages.append(contentsOf: chatHistory(expert: expert))
        return aiMessages
    }
    
    private func instructions(expert: CDExpert, relevantChunks: [CDTextChunk]) -> AIMessage {
        let description = "You are an expert on the following topic(s): \(expert.desc ?? "The information provided below").\n"
//        let introduction = "Use the information provided below to answer questions relevant to your area of expertise. If the answer cannot be found in the text provided, write \"I could not find an answer.\""
        let introduction = "Only answer questions relevant to your area of expertise. If you don't know the answer, write \"I could not find an answer.\""
        
        var relevantText = ""
        for chunk in relevantChunks {
            if let text = chunk.text {
                relevantText += "\nRelevant Text:\n\(text)\n"
            }
        }
        return AIMessage(role: .system, content:description + introduction + relevantText)
    }
    
    private func chatHistory(expert: CDExpert, messageCount: Int = 5) -> [AIMessage] {
        let exchanges = expert.chatExchanges(in: 0..<messageCount)
        var messages = [AIMessage]()
        for exchange in exchanges {
            if let query = exchange.query {
                messages.append(AIMessage(role: .user, content: query))
            }
            if let response = exchange.response {
                messages.append(AIMessage(role: .assistant, content: response))
            }
        }
        return messages
    }
}
