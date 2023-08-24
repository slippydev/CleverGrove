//
//  OpenAICoordinator.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import Foundation
import OpenAIKit
import OSLog
import SwiftUI
import CoreData

class OpenAICoordinator {
    static let shared = OpenAICoordinator()
    let openAI: OpenAIKit
    var openAIEmbedding = OpenAI()
    let promptBuilder = PromptBuilder()
    
    private init() {
        openAI = OpenAIKit(apiToken: KeyStore.key(from: .openAI).api_key,
                           organization: KeyStore.key(from: .openAI).org_key)
    }
    
    func getEmbeddings(for text: String) async throws -> EmbeddingsResponse? {
        return try await openAIEmbedding.getEmbeddings(input: text)
    }
    
    func getEmbeddings(for chunks: [String], progressHandler: @escaping (Double) -> Void) async throws -> [[Double]] {
        let result: [Int: [Double]] = try await openAIEmbedding.getEmbeddings(input: chunks, progressHandler: progressHandler)
        var embeddings = [[Double]]()
        for i in 0..<result.count {
            guard let embedding = result[i] else { throw OpenAIError.jsonDecodingError }
            embeddings.append(embedding)
        }
        return embeddings
    }
    
    func ask(question: String, expert: CDExpert) async throws -> (String, [CDTextChunk]) {
        // Find the most relevant text chunks from documents attached to this expert
        let relevantChunks = try await nearest(query: question, expert: expert)
        
        // Build up the context for the GPT to refer to including relevant text chunks and
        // past conversation.
        let context = promptBuilder.context(relevantChunks: relevantChunks, expert: expert)
        var answer = ""
        
        // Logging for debugging prompts
        for section in context {
            Logger().info("[\(section.role.rawValue)]:")
            Logger().info("\(section.content)\n")
        }
        Logger().info("Question: \(question)\n")
        
        // Send the message and context to OpenAI
        let result = await openAI.sendChatCompletion(newMessage: AIMessage(role: .user, content: question),
                                                     previousMessages: context,
                                                     model: .gptV3_5(.gptTurbo),
                                                     maxTokens: 256,
                                                     temperature: 1.0)
        switch result {
        case .success(let aiResult):
            answer = aiResult.choices.first?.message?.content ?? ""
        case .failure(let error):
            // FIXME: This prints the error into the chat response. Not sure if this makes sense. Better to have a more natural response.
            answer = error.localizedDescription
            let errorInfo = (error as NSError).userInfo["error"]! as! [String:Any]
            if let code = errorInfo["code"], let message = errorInfo["message"] {
                print(code)
                print(message)
            }
        }
        return (answer, relevantChunks)
    }
    
    func introduction(of expert: CDExpert) async -> String? {
        guard let exchanges = expert.chatExchanges, exchanges.count == 0 else { return nil }
        
        let trainingTitles = expert.trainingDocumentTitles
        let instructions = promptBuilder.introduction(name: expert.name ?? "",
                                                      expertise: expert.desc ?? "",
                                                      style: expert.communicationStyle,
                                                      training: trainingTitles)
        Logger().info("Introduction Instructions: \(instructions)\n")
        
        let result = await openAI.sendChatCompletion(newMessage: AIMessage(role: .system, content: instructions),
                                                     previousMessages: [],
                                                     model: .gptV3_5(.gptTurbo),
                                                     maxTokens: 512,
                                                     temperature: 1.0)
        var introduction = ""
        switch result {
        case .success(let aiResult):
            introduction = aiResult.choices.first?.message?.content ?? ""
        case .failure(_): break // Do nothing if the introduction fails.
        }
        return introduction
    }
    
//    func establishTone(of expert: CDExpert, from textChunks: [String]) async -> String? {
//        var text: String = ""
//        let range = 0..<min(5, textChunks.count)
//        for i in range {
//            text.append(textChunks[i])
//        }
//        let message = promptBuilder.documentTone(text: text)
//        let result = await openAI.sendChatCompletion(newMessage: AIMessage(role: .system, content: message),
//                                                     previousMessages: [],
//                                                     model: .gptV3_5(.gptTurbo),
//                                                     maxTokens: 512,
//                                                     temperature: 1.0)
//        var expertTone: String?
//        switch result {
//        case .success(let aiResult):
//            expertTone = aiResult.choices.first?.message?.content ?? ""
//        case .failure(let error):
//            print("establishTone Error: \(error.localizedDescription)")
//        }
//        return expertTone
//    }
    
    private func nearest(query: String, expert: CDExpert, max: Int = 4, usePastQueries: Bool = false) async throws -> [CDTextChunk] {
        let textChunks = expert.textChunksAsArray
        var queryEmbedding: [Double]
        if usePastQueries {
            let pastQueries = expert.pastQueries(in: 0..<5) // include the most recent queries in the query embedding to provide more context
            Logger().info("Calculating Query Embeddings for: \(pastQueries)\n\(query)\n")
            queryEmbedding = try await getEmbeddings(for: "\(pastQueries)\n\(query)")?.embedding ?? [Double]()
        } else {
            Logger().info("Calculating Query Embedding for: \(query)\n")
            queryEmbedding = try await getEmbeddings(for: "\(query)")?.embedding ?? [Double]()
        }
        let (strings, _) = await stringsRankedByRelatedness(queryEmbedding: queryEmbedding, textChunks: textChunks)
        let shortList = Array(strings.prefix(max))
        let relevantChunks = expert.findTextChunks(with: shortList)
        return relevantChunks
    }
    
    private func stringsRankedByRelatedness(queryEmbedding: [Double], textChunks: [CDTextChunk]) async -> (strings: [String], relatednesses: [Double]) {
        let embeddings = CDTextChunk.embeddingsArrayFrom(textChunks: textChunks)
        var result: [(String, Double)] = []
        for (_, row) in embeddings.enumerated() {
            let relatedness = cosineSimilarity(queryEmbedding, row.value)
            result.append((row.key, relatedness))
        }
        
        result.sort { $0.1 > $1.1 }
        let strings = result.map { $0.0 }
        let relatednesses = result.map { $0.1 }
        return (strings, relatednesses)
    }
    
    private func cosineSimilarity(_ vector1: [Double], _ vector2: [Double]) -> Double {
        assert(vector1.count == vector2.count, "Vectors must have the same length.")
        
        let dotProduct = zip(vector1, vector2).map(*).reduce(0.0, +)
        let magnitude1 = sqrt(vector1.map { $0 * $0 }.reduce(0.0, +))
        let magnitude2 = sqrt(vector2.map { $0 * $0 }.reduce(0.0, +))
        
        guard magnitude1 != 0 && magnitude2 != 0 else {
            return 0.0 // Return 0 if any vector has zero magnitude (to handle zero vectors)
        }
        
        return dotProduct / (magnitude1 * magnitude2)
    }
}
