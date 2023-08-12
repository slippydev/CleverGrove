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
    let openAIEmbedding = OpenAI()
    
    private init() {
        openAI = OpenAIKit(apiToken: KeyStore.key(from: .openAI).api_key,
                           organization: KeyStore.key(from: .openAI).org_key)
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
    
    func getEmbeddings(for chunks: [String]) async -> Result<[[Double]], OpenAIError> {
        let result = await openAIEmbedding.getEmbeddings(input: chunks)
        var embeddings = [[Double]]()
        switch result {
        case .success(let dictOfEmbeddings):
            for i in 0..<dictOfEmbeddings.count {
                guard let embedding = dictOfEmbeddings[i] else { return .failure(.jsonDecodingError) }
                embeddings.append(embedding)
            }
            return .success(embeddings)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func ask(question: String, expert: CDExpert) async -> String {
        var answer = ""
        let message = await queryMessage(query: question, expert: expert)
        
        Logger().info("MESSAGE TO OPENAI:\n\n===========\n\n\(message)\n\n===========\n\n")
        
        let result = await openAI.sendChatCompletion(newMessage: AIMessage(role: .user, content: message), model: .gptV3_5(.gptTurbo), maxTokens: 512, temperature: 1.0)
        switch result {
        case .success(let aiResult):
            answer = aiResult.choices.first?.message?.content ?? ""
        case .failure(let error):
            answer = error.localizedDescription
        }
        return answer
    }
    
    private func queryMessage(query: String, expert: CDExpert) async -> String {
        let allEmbeddings = embeddingsForExpert(expert: expert)
        let relevantTexts = await nearest(query: query, embeddings: allEmbeddings)
        let description = expert.desc ?? ""
        let introduction = "You are playing the role of an expert on the following topic:\n \(description) Use the information below to answer questions relevant to your area of expertise. These document sections are most relevant to the question. If the answer cannot be found in the documents provided, write \"I could not find an answer.\""
        var message = introduction
        
        for text in relevantTexts {
            let nextSection = "\n\nDocument section:\n\"\"\"\n\(text)\n\"\"\""
            message += nextSection
        }
        let question = "\n\nQuestion: \(query)"
        
        return message + question
    }
    
    private func embeddingsForExpert(expert: CDExpert) -> [String: [Double]] {
        let moc = DataController.shared.managedObjectContext
        let fetchRequest = CDTextChunk.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "expert == %@", expert as CVarArg)
        guard let textChunks = try? moc.fetch(fetchRequest) else  { return [String: [Double]]() }
        var embeddings = [String: [Double]]()
        for chunk in textChunks {
            if let text = chunk.text {
                embeddings[text] = chunk.embeddingAsArray
            }
        }
        return embeddings
    }
    
    private func nearest(query: String, embeddings: [String: [Double]], max: Int = 3) async -> [String] {
        let (strings, _) = await stringsRankedByRelatedness(query: query, embeddings: embeddings)
        return Array(strings.prefix(max))
    }
    
    private func stringsRankedByRelatedness(query: String, embeddings: [String : [Double]]) async -> (strings: [String], relatednesses: [Double]) {
        let queryEmbedding = await getEmbeddings(for: query)?.embedding ?? [Double]()
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
