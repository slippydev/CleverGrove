//
//  TextChunk.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//

import Foundation

struct TextChunk: Identifiable {
    let id: UUID
    let text: String
    let embedding: [Double]
    
    init(id: UUID = UUID(), text: String, embedding: [Double]) {
        self.id = id
        self.text = text
        self.embedding = embedding
    }
    
    var embeddingAsString: String {
        embedding.map { String($0) }.joined(separator: ", ")
    }
    
    static func embedding(from text: String) -> [Double] {
        return text
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
}
