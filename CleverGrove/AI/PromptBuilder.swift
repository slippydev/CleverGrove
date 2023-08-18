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
    
    func introduction(name: String, expertise: String, training: [String]) -> String {
        var intro: String
        let hasTraining = training.count > 0
        if hasTraining {
            intro = "Your name is \(name), and you are an expert at \(expertise). Introduce yourself and offer to answer any questions about your area of expertise. Your introduction should be 100 words or less. List some of these files you've been trained but don't include the file extensions:\n"
            for document in training {
                intro += "\(document)\n"
            }
        } else {
            intro = "Your name is \(name), and you are an expert at \(expertise). You haven't been trained yet, so introduce yourself and suggest the user add some training documents to you before you can actually help them by answering questions. Your response should be 100 words or less. Explain that to add training documents they need to swipe on your entry in the Expert List and tap 'Edit' and then add documents. You currently support PDF and Text files."
        }
        return intro
    }
    
    private func instructions(expert: CDExpert, relevantChunks: [CDTextChunk]) -> AIMessage {
        
        let description = "Your name is \(expert.name ?? "") and you are an expert on the following topic(s): \(expert.desc ?? "Use the information provided below").\n"
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
