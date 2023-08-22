//
//  DocumentParser.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum ParserError: Error {
    case parsingError
    case fileTypeError
}

struct DocumentParser {
    
    let data: Data
    let dataType: UTType
    let document: CDDocument
    let expert: CDExpert
    
    let batchSize = 1024  // can submit up to 2048 embedding inputs per request
    private let ai = OpenAICoordinator.shared
    private let moc = DataController.shared.managedObjectContext
    
    func parse(progressHandler: @escaping (Double) -> Void) async throws {
        
        let textChunks = try DocumentDecode.decode(data: data, type: dataType, chunkSize: batchSize)
        let embeddings = try await ai.getEmbeddings(for: textChunks, progressHandler:progressHandler)
        
        // Create an array of CDTextChunk objects out of the document
        guard textChunks.count == embeddings.count else { throw OpenAIError.jsonDecodingError }
        for (i, chunk) in textChunks.enumerated() {
            let embedding = embeddings[i]
            // FIXME: There's no real need for TextChunk other than in this method call. Fix it
            let managedTextChunk = CDTextChunk.managedTextChunk(from: TextChunk(text: chunk, embedding:embedding), context: moc)
            expert.addToTextChunks(managedTextChunk)
            document.addToTextChunks(managedTextChunk)
        }
        
    }
}

extension String {
    func splitIntoChunks(ofSize chunkSize: Int) -> [String] {
        var startIndex = self.startIndex
        var chunks: [String] = []
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: chunkSize, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = self[startIndex..<endIndex]
            chunks.append(String(chunk))
            startIndex = endIndex
        }
        
        return chunks
    }
}
