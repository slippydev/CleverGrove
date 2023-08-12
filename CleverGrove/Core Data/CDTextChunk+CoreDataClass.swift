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
    static func managedTextChunk(from textChunk: TextChunk, context: NSManagedObjectContext) -> CDTextChunk {
        var managedTextChunk = CDTextChunk(context: context)
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
}
