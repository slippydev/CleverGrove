//
//  ExpertExporter.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import Foundation
import Zip
import UniformTypeIdentifiers

// THIS CODE IS NO LONGER BEING USED SINCE REMOVING EXPERT SHARING CODE.
// LEAVING IT HERE FOR FUTURE REFERENCE


/**
 A structure representing a JSON object for text chunks.
 
 - Properties:
 - id: The unique identifier for the text chunk.
 - embedding: The embedding data associated with the text chunk.
 - text: The text content of the chunk.
 - index: The index of the text chunk.
 
 - Initializer:
 - Parameters:
 - textChunk: The `CDTextChunk` object from which to create the JSON representation.
 */
struct TextChunkJSON: Codable {
    let id: UUID
    let embedding: String?
    let text: String?
    let index: Int16
    
    init(from textChunk: CDTextChunk) {
        id = textChunk.id ?? UUID()
        embedding = textChunk.embedding
        text = textChunk.text
        index = textChunk.index
    }
}

/**
 A structure representing a JSON object for a document.
 
 - Properties:
 - id: The unique identifier for the document.
 - fileName: The name of the file.
 - filetype: The file type.
 - path: The path of the document.
 - status: The status of the document.
 - title: The title of the document.
 - textChunks: An array of `TextChunkJSON` objects representing text chunks.
 
 - Initializer:
 - Parameters:
 - document: The `CDDocument` object from which to create the JSON representation.
 */
struct DocumentJSON: Codable {
    let id: UUID
    let fileName: String?
    let filetype: String?
    let path: String?
    let status: String?
    let title: String?
    var textChunks: [TextChunkJSON]
    
    init(from document: CDDocument) {
        id = document.id ?? UUID()
        fileName = document.fileName
        filetype = document.filetype
        path = document.path
        status = document.status
        title = document.title
        textChunks = []
        if let docTextChunks = document.orderedTextChunks() {
            for chunk in docTextChunks {
                textChunks.append(TextChunkJSON(from: chunk))
            }
        }
    }
}

/**
 A structure representing a JSON object for an expert.
 
 - Properties:
 - id: The unique identifier for the expert.
 - image: The image associated with the expert.
 - lastUpdated: The date when the expert was last updated.
 - name: The name of the expert.
 - personality: The personality of the expert.
 - expertise: The area of expertise of the expert.
 - documents: An array of `DocumentJSON` objects representing documents associated with the expert.
 
 - Initializer:
 - Parameters:
 - expert: The `CDExpert` object from which to create the JSON representation.
 */
struct ExpertJSON: Codable {
    let id: UUID
    let image: String?
    let lastUpdated: Date?
    let name: String?
    let personality: String?
    let expertise: String?
    var documents: [DocumentJSON]
    
    init(from expert: CDExpert) {
        id = expert.id ?? UUID()
        image = expert.image
        lastUpdated = expert.lastUpdated
        name = expert.name
        personality = expert.personality
        expertise = expert.expertise
        documents = []
        for document in expert.documentsAsArray {
            documents.append(DocumentJSON(from: document))
        }
    }
}

/**
 A structure responsible for exporting an expert to a JSON file.
 
 - Properties:
 - expert: The expert to export.
 
 - Methods:
 - export(to:): Exports the expert to a JSON file.
 */
struct ExpertExporter {
    static let expertJSONSubpath = "expert.json"
    
    let expert: CDExpert
    
    /**
     Exports the expert to a JSON file with the given filename.
     
     - Parameters:
     - filename: The filename for the exported JSON file.
     
     - Throws: An error if there is an issue with exporting.
     
     - Returns: The URL of the exported JSON file.
     */
    func export(to filename: String) throws -> URL {
        let data = try encodeToJSON()
        let url = try save(data: data, to: filename)
        return url
    }
    
    private func encodeToJSON() throws -> Data {
        let codableExpert = ExpertJSON(from: expert)
        let encoder = JSONEncoder()
        let data = try encoder.encode(codableExpert)
        return data
    }
    
    private func save(data: Data, to filename: String) throws -> URL {
        let url = URL.documents.appendingPathComponent(filename)
        let archive = ArchiveFile(filename: ExpertExporter.expertJSONSubpath, data: data as NSData, modifiedTime: Date.now)
        try Zip.zipData(archiveFiles: [archive], zipFilePath: url, password: nil, progress: nil)
        return url
    }
}


