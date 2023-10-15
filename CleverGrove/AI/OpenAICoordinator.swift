//
//  OpenAICoordinator.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import Foundation
import SwiftUI
import CoreData

class OpenAICoordinator {
    static let shared = OpenAICoordinator()
    var openAI: OpenAI
    let promptBuilder = PromptBuilder()
    let aiLogger = CGLogger()
    let network = HTTPNetwork()
    let relevancyThreshold = 0.70 // any text chunks with less relevancy than this compared to the query are disqualified
    
    private init() {
        openAI = OpenAI(openAIKey: KeyStore.key(from: .openAI).api_key, network: network, logger: aiLogger)
    }
    
    func getEmbeddings(for text: String) async throws -> EmbeddingsResponse? {
        return try await openAI.getEmbeddings(input: text)
    }
    
    func getEmbeddings(for chunks: [String]) async throws -> [[Double]] {
        let result: [Int: [Double]] = try await openAI.getEmbeddings(input: chunks)
        var embeddings = [[Double]]()
        for i in 0..<result.count {
            guard let embedding = result[i] else { throw HTTPError.jsonDecodingError }
            embeddings.append(embedding)
        }
        return embeddings
    }
    
    func ask(question: String, expert: CDExpert) async throws -> (String, [CDTextChunk]) {
        // Find the most relevant text chunks from documents attached to this expert
        var relevantChunks = try await nearest(query: question, expert: expert, relevancyThreshold: relevancyThreshold)
        
        // If the expert has been updated since the last chat exchange, don't include the chat history because it will
        // interfere in the application of the changes to the expert.
        var chatHistoryCount = 0
        if let lastexchange = expert.mostRecentChatExchange(), let timestamp = lastexchange.timestamp {
            if (expert.updatedSince(date: timestamp) == false) {
                chatHistoryCount = 3 // include up to 3 previous chat exchanges
            }
        }
        
        // We need to handle failures of the chat completion gracefully. The main reason it fails is exceeding the token count, so
        // retry with fewer relevant chunks and text history. If that still fails throw an error.
        var retryCount = 0
        let maxRetries = 4
        while retryCount < maxRetries {
            do {
                let response = try await sendChat(question: question, relevantChunks: relevantChunks, expert: expert, chatHistoryCount: chatHistoryCount)
                return (response, relevantChunks)
            } catch {
                retryCount += 1
                if retryCount < maxRetries {
                    // retry the chat but with less context
                    chatHistoryCount = max(0, chatHistoryCount - 1)
                    relevantChunks.removeLast()
                } else {
                    throw error
                }
            }
        }
        return ("Sorry, I am having a problem answering this question", relevantChunks)
    }
    
    func sendChat(question: String, relevantChunks: [CDTextChunk], expert: CDExpert, chatHistoryCount: Int) async throws -> String {
        // Build up the context for the GPT to refer to including relevant text chunks and past conversation.
        let context = promptBuilder.context(relevantChunks: relevantChunks, expert: expert, chatHistoryCount: chatHistoryCount)
        
        aiLogger.logChat(context: context, question: question)
        
        // Send the message and context to OpenAI
        let result = try await openAI.sendChatCompletion(newMessage: AIMessage(role: .user, content: question),
                                                     previousMessages: context,
                                                     maxTokens: 1024,
                                                     temperature: 1.0,
                                                     frequencyPenalty: 2.0,
                                                     presencePenalty: 2.0)
        let answer = result.message?.content ?? ""
        let tokenUsage = result.usage?.totalTokens ?? 0
        CGLogger().log(.chatExchange, params: [AnalyticsParams.tokenCount.rawValue: tokenUsage])
        
        return answer
    }
    
    
    func introduction(of expert: CDExpert) async throws -> String? {
        guard let exchanges = expert.chatExchanges, exchanges.count == 0 else { return nil }
        
        let trainingTitles = expert.trainingDocumentTitles
        let instructions = promptBuilder.introduction(name: expert.name ?? "",
                                                      expertise: expert.expertise ?? "",
                                                      style: expert.communicationStyle,
                                                      training: trainingTitles)
        aiLogger.logIntro(instructions: instructions)
        
        let result = try await openAI.sendChatCompletion(newMessage: AIMessage(role: .system, content: instructions),
                                                     previousMessages: [],
                                                     maxTokens: 512,
                                                     temperature: 1.0)
        let introduction = result.message?.content ?? ""
        return introduction
    }
    
    func extractExpertise(from textChunks: [CDTextChunk]) async throws -> (String?, String?) {
        struct ExpertiseJSON: Codable {
            public let title: String
            public let expertise: String
        }
        
        var text: String = ""
        let range = 0..<min(5, textChunks.count)
        for i in range {
            if let string = textChunks[i].text {
                text.append(string)
            }
        }
        let message = promptBuilder.documentExpertiseArea(referenceText: text)
        let result = try await openAI.sendChatCompletion(newMessage: message,
                                                     previousMessages: [],
                                                     maxTokens: 512,
                                                     temperature: 1.0)
        let json = result.message?.content ?? ""
        let jsonObject = try JSONDecoder().decode(ExpertiseJSON.self, from: Data(json.utf8)) as ExpertiseJSON
        return (jsonObject.title, jsonObject.expertise)
    }
    
    private func nearest(query: String, expert: CDExpert, max: Int = 4, relevancyThreshold: Double, usePastQueries: Bool = false) async throws -> [CDTextChunk] {
        let textChunks = expert.textChunksAsArray
        var queryEmbedding: [Double]
        if usePastQueries {
            let pastQueries = expert.pastQueries(in: 0..<5) // include the most recent queries in the query embedding to provide more context
            queryEmbedding = try await getEmbeddings(for: "\(pastQueries)\n\(query)")?.embedding ?? [Double]()
        } else {
            queryEmbedding = try await getEmbeddings(for: "\(query)")?.embedding ?? [Double]()
        }
        let result = await textChunksRankedByRelatedness(queryEmbedding: queryEmbedding, textChunks: textChunks)
        let relevantChunks = filterRelevantTextChunks(textChunkTuples: result, max: max, relevancyThreshold: relevancyThreshold)
        return relevantChunks
    }
    
    private func filterRelevantTextChunks(textChunkTuples: [(CDTextChunk, Double)], max: Int, relevancyThreshold: Double) -> [CDTextChunk] {
        let result = textChunkTuples
            .filter { $0.1 >= relevancyThreshold }
            .map { $0.0 }
            .prefix(max)
        return Array(result)
    }
    
    private func textChunksRankedByRelatedness(queryEmbedding: [Double], textChunks: [CDTextChunk]) async -> [(CDTextChunk, Double)] {
        var result: [(CDTextChunk, Double)] = []
        for chunk in textChunks {
            let relatedness = cosineSimilarity(queryEmbedding, chunk.embeddingAsArray)
            result.append((chunk, relatedness))
        }
        result.sort { $0.1 > $1.1 }
        
        aiLogger.logRelatedness(relatedness: result.map { $0.1 })
        return result
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
