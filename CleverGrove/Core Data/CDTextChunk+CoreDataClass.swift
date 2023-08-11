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
    static func managedTextChunk(from textChunk: TextChunk, context: NSManagedObjectContext, dataController: DataController) -> CDTextChunk {
        var managedTextChunk = CDTextChunk(context: context)
        managedTextChunk.id = textChunk.id
        managedTextChunk.document = dataController.fetchDocument(id: textChunk.document.id)
        managedTextChunk.expert = dataController.fetchExpert(id: textChunk.expert.id)
        managedTextChunk.text = textChunk.text
        managedTextChunk.embedding = textChunk.embeddingAsString
        return managedTextChunk
    }
    
    func textChunk() -> TextChunk {
        // FIXME: Force unwrapping document and expert is a bad idea
        return TextChunk(id: id ?? UUID(),
                         text: text ?? "",
                         embedding: TextChunk.embedding(from: embedding ?? ""),
                         document: document!.document(),
                         expert: expert!.expertProfile())
    }
}
