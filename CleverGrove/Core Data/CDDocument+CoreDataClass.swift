//
//  CDDocument+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//
//

import Foundation
import CoreData

@objc(CDDocument)
public class CDDocument: NSManagedObject {
    
    static func document(context: NSManagedObjectContext, fileURL: URL, fileType: FileType, status: DocumentStatus) -> CDDocument {
        let document = CDDocument(context: context)
        document.id = UUID()
        document.path = fileURL.absoluteString
        document.fileName = fileURL.lastPathComponent
        document.filetype = fileType.rawValue
        document.status = status.rawValue
        return document
    }
    
    static func document(from json: DocumentJSON, context: NSManagedObjectContext) -> CDDocument {
        let document = CDDocument(context: context)
        document.id = json.id
        document.path = json.path
        document.fileName = json.fileName
        document.filetype = json.filetype
        document.status = json.status
        document.title = json.title
        for textChunkJSON in json.textChunks {
            document.addToTextChunks(CDTextChunk.textChunk(from: textChunkJSON, context: context))
        }
        return document
    }
    
    func orderedTextChunks() -> [CDTextChunk]? {
        guard let textChunks = textChunks?.allObjects as? [CDTextChunk] else { return nil }
        let sortedArray = textChunks.sorted { $0.index < $1.index }
        return sortedArray
    }
}
