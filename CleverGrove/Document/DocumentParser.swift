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
    
    let data: Data
    let document: CDDocument
    let expert: CDExpert
    let batchSize = 1024  // can submit up to 2048 embedding inputs per request
    private let ai = OpenAICoordinator.shared
    private let moc = DataController.shared.managedObjectContext
    
    func parse() async throws {
        let str = String(decoding: data, as: UTF8.self)
        let chunks = str.splitIntoChunks(ofSize: batchSize)
        let result = await ai.getEmbeddings(for: chunks)
        
        // Create an array of CDTextChunk objects out of the document
        switch result {
        case .success(let embeddings):
            guard chunks.count == embeddings.count else { throw OpenAIError.jsonDecodingError }
            for (i, chunk) in chunks.enumerated() {
                let embedding = embeddings[i]
                // FIXME: There's no real need for TextChunk other than in this method call. Fix it
                let managedTextChunk = CDTextChunk.managedTextChunk(from: TextChunk(text: chunk, embedding:embedding), context: moc)
                expert.addToTextChunks(managedTextChunk)
                document.addToTextChunks(managedTextChunk)
            }
        case .failure(let error):
            print(error.localizedDescription)
            throw ParserError.parsingError
        }
        
        // Save the chunks to Core Data
        do {
            try moc.save()
        } catch {
            throw ParserError.parsingError
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
