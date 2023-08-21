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
        guard let decoder = documentDecoder(for: dataType) else {
            return // FIXME: probably want to let the user know
        }
        var chunks = [String]()
        do {
            chunks = try decoder.decode(from: data, chunkSize: batchSize)
        } catch {
            throw error
        }
        let result = await ai.getEmbeddings(for: chunks, progressHandler:progressHandler)
        
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
    }
    
    private func documentDecoder(for type: UTType) -> DocumentDecoder? {
        if type.conforms(to: .text) {
            return TextDecoder()
        } else if type.conforms(to: .pdf) {
            return PDFDecoder()
        } else if type.conforms(to: .docx) {
            return DocxDecoder()
        } else {
            return nil
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
