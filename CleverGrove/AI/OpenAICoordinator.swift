//
//  OpenAICoordinator.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import Foundation
import OpenAIKit
import OSLog

class OpenAICoordinator {
    let openAI: OpenAIKit
    let openAIEmbedding = OpenAI()
    var embeddings: Embeddings = Embeddings(modelName: "hi_rules")
    
    init(key: String, org: String) {
        openAI = OpenAIKit(apiToken: key, organization: org)
    }
    
    func getEmbeddings(for text: String) async -> EmbeddingsResponse? {
        let result = await openAIEmbedding.getEmbeddings(input: text)
        switch result {
        case .success(let embeddings):
            return embeddings
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }
    }
    
    func ask(question: String) async -> String {
        var answer = ""
        let message = queryMessage(query: question)
        
        Logger().info("MESSAGE TO OPENAI:\n\n===========\n\n\(message)\n\n===========\n\n")
        
        let result = await openAI.sendChatCompletion(newMessage: AIMessage(role: .user, content: message), model: .gptV3_5(.gptTurbo), maxTokens: 512, temperature: 2.0)
        switch result {
        case .success(let aiResult):
            answer = aiResult.choices.first?.message?.content ?? ""
        case .failure(let error):
            answer = error.localizedDescription
        }
        return answer
    }
    
    private func queryMessage(query: String) -> String {
        let relevantTexts = embeddings.nearest(query: query)
        
        let introduction = "Use the below rules about a game to answer questions about the rules. If the answer cannot be found in the rules, write \"I could not find an answer.\""
        var message = introduction
        
        for text in relevantTexts {
            let nextSection = "\n\nGame rules section:\n\"\"\"\n\(text)\n\"\"\""
            message += nextSection
        }
        let question = "\n\nQuestion: \(query)"
        
        return message + question
    }
}
