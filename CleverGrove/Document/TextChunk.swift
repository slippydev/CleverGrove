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
    let document: DocumentInfo
    let expert: ExpertProfile
    
    init(id: UUID = UUID(), text: String, embedding: [Double], document: DocumentInfo, expert: ExpertProfile) {
        self.id = id
        self.text = text
        self.embedding = embedding
        self.document = document
        self.expert = expert
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
