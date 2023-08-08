//
//  Embeddings.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-08-03.
//

import NaturalLanguage


struct Embeddings {
    
    // NLEmbedding creates embedding vectors of size 512, while OpenAI creates much larger vectors,
    // so we need to truncate the one we import  from OpenAI
    private let EMBEDDING_VECTOR_DIM = 512
    
    private struct EmbeddingDictStructure: Codable {
        let text: String
        let embedding: [Double]
    }
    
    var embedding: [String: [Double]]?
    
    init(modelName: String) {
        embedding = loadJSONEmbeddingsIntoDictionary(fileInBundle: modelName)
    }
    
    private func loadJSONEmbeddingsIntoDictionary(fileInBundle fileName: String) -> [String: [Double]]? {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else { return nil }
        guard let jsonData = try? Data(contentsOf: fileURL) else { return nil }
        guard let embeddings = try? JSONDecoder().decode([EmbeddingDictStructure].self, from: jsonData) else { return nil }
        
        var result: [String: [Double]] = [:]
        for embedding in embeddings {
            result[embedding.text] = Array(embedding.embedding.prefix(EMBEDDING_VECTOR_DIM))
        }
        return result
    }
    
    func nearest(query: String, max: Int = 3) -> [String] {
        guard let embedding = embedding else { return [String]() }
        let (strings, _) = stringsRankedByRelatedness(query: query, customEmbeddings: embedding)
        return Array(strings.prefix(max))
    }
    
    private func stringsRankedByRelatedness(query: String, customEmbeddings: [String : [Double]]) -> (strings: [String], relatednesses: [Double]) {
        
        let queryEmbedding = NLEmbedding.sentenceEmbedding(for: .english)?.vector(for: query) ?? [Double]()
        var result: [(String, Double)] = []
        for (_, row) in customEmbeddings.enumerated() {
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
