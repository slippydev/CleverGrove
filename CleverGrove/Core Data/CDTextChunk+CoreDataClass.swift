//
//  CDTextChunk+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//
//

import Foundation
import CoreData

@objc(CDTextChunk)
public class CDTextChunk: NSManagedObject {
    
    var embeddingAsArray: [Double] {
        (embedding ?? "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
    func embeddingStringFrom(embeddingArray: [Double]) -> String {
        return embeddingArray.map { String($0) }.joined(separator: ", ")
    }
    
    static func managedTextChunk(from textChunk: TextChunk, context: NSManagedObjectContext) -> CDTextChunk {
        let managedTextChunk = CDTextChunk(context: context)
        managedTextChunk.id = textChunk.id
        managedTextChunk.text = textChunk.text
        managedTextChunk.embedding = textChunk.embeddingAsString
        return managedTextChunk
    }
    
    func textChunk() -> TextChunk {
        return TextChunk(id: id ?? UUID(),
                         text: text ?? "",
                         embedding: TextChunk.embedding(from: embedding ?? ""))
    }
    
    static func embeddingsArrayFrom(textChunks: [CDTextChunk]) -> [String: [Double]] {
        var embeddings = [String: [Double]]()
        for chunk in textChunks {
            if let text = chunk.text {
                embeddings[text] = chunk.embeddingAsArray
            }
        }
        return embeddings
    }
    
}
