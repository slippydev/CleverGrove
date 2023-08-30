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
    
    static func textChunk(context: NSManagedObjectContext, text: String, index: Int, embedding: [Double]) -> CDTextChunk {
        let textChunk = CDTextChunk(context: context)
        textChunk.id = UUID()
        textChunk.index = Int16(index)
        textChunk.text = text
        textChunk.embedding = embeddingStringFrom(embeddingArray: embedding)
        return textChunk
    }
    
    static func textChunk(from json: TextChunkJSON, context: NSManagedObjectContext) -> CDTextChunk {
        let textChunk = CDTextChunk(context: context)
        textChunk.id = json.id
        textChunk.index = json.index
        textChunk.text = json.text
        textChunk.embedding = json.embedding
        return textChunk
    }
    
    var embeddingAsArray: [Double] {
        (embedding ?? "")
            .split(separator: ",")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
    }
    
    static func embeddingStringFrom(embeddingArray: [Double]) -> String {
        return embeddingArray.map { String($0) }.joined(separator: ", ")
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
