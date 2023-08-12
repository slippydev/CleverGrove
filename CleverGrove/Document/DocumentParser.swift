//
//  DocumentParser.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//

import Foundation
import SwiftUI

enum ParserError: Error {
    case parsingError
}

struct DocumentParser {
    @Environment(\.aiCoordinator) var ai
    @Environment(\.managedObjectContext) var moc
    
    let data: Data
    let document: CDDocument
    let expert: CDExpert
    let batchSize = 1024  // can submit up to 2048 embedding inputs per request
    
    func chunkify() -> [String] {
        let str = String(decoding: data, as: UTF8.self)
        let chunks = str.splitIntoChunks(ofSize: batchSize)
        return chunks
    }
    
    func parse() async throws {
        let chunks = chunkify()
        let result = await ai.getEmbeddings(for: chunks)
        
        // Create an array of CDTextChunk objects out of the document
        switch result {
        case .success(let embeddings):
            guard chunks.count == embeddings.count else { throw OpenAIError.jsonDecodingError }
            for (i, chunk) in chunks.enumerated() {
                let embedding = embeddings[i]
                let managedTextChunk = CDTextChunk.managedTextChunk(from: TextChunk(text: chunk, embedding:embedding), context: moc)
                expert.addToTextChunks(managedTextChunk)
                document.addToTextChunks(managedTextChunk)
            }
        case .failure(let error):
            print(error.localizedDescription)
            throw ParserError.parsingError
//            return error
        }
        
        // Save the chunks to Core Data
        do {
            try moc.save()
        } catch {
            throw ParserError.parsingError
        }
        
//        return nil // if we've come this far all went well
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
