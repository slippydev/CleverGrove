//
//  ExpertExporter.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import Foundation
import Zip
import UniformTypeIdentifiers

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

enum FileError: Error {
    case exportError
    case importError
}

struct ExpertExporter {
    static let expertJSONSubpath = "expert.json"
    
    let expert: CDExpert
    
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

struct ExpertImporter {
    private let fileReader = FileReader()
    
    func read(url: URL) throws -> ExpertJSON {
        guard let (data, type) = fileReader.openFile(at: url) as? (Data, UTType) else {
            throw FileError.importError
        }
        guard type.conforms(to: .expertFileFormat) else { throw FileError.importError }
        
        return try decodeFromJSON(data: data)
    }
    
    func decodeFromJSON(data: Data) throws -> ExpertJSON {
        let decoder = JSONDecoder()
        let expertJSON = try decoder.decode(ExpertJSON.self, from: data)
        return expertJSON
    }
}
