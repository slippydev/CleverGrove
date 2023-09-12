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

struct ParseResult {
    let embeddings: [[Double]]
    let textChunks: [String]
}

@MainActor
final class Parser: ObservableObject {
    private let batchSize = 2048  // can submit up to 2048 embedding inputs per request
    private let ai = OpenAICoordinator.shared

    func parse(document: CDDocument, data: Data, dataType: UTType, progressHandler: @escaping (Double) -> Void) async throws -> ParseResult {
        let result = try await withThrowingTaskGroup(of: ParseResult.self) { group -> ParseResult in
            let textChunks = try DocumentDecode.decode(data: data, type: dataType, chunkSize: batchSize)

            let batchSize = 40
            let totalChunks = textChunks.count // so our progress calculations are correct
            var embeddings: [[Double]] = []
            for startIndex in stride(from: 0, to: textChunks.count, by: batchSize) {
                let endIndex = Swift.min(startIndex + batchSize, textChunks.count)
                let batchOfTextChunks = Array(textChunks[startIndex..<endIndex])
                // Now you have a batch of batchSize (or less) elements to work with
                let embeddingsBatch = try await ai.getEmbeddings(for: batchOfTextChunks)
                progressHandler(Double(endIndex) / Double(totalChunks))
                embeddings.append(contentsOf: embeddingsBatch)
            }
            return ParseResult(embeddings: embeddings, textChunks: textChunks)
        }
        return result
    }
    
    func getExpertise(for expert: CDExpert, from document: CDDocument) async throws {
        guard let textChunks = document.orderedTextChunks() else { throw ParserError.parsingError }
        if case let (title?, expertise?) = try await ai.extractExpertise(from: textChunks) {
            if expert.expertise == nil {
                // don't change the expertise from the originally established if user is adding more documents
                expert.expertise = expertise
            }
            document.title = title
        } else {
            // We failed to derive an expertise, just let the title be empty
            document.title = document.fileName // If we failed to extract a document title, just fall back to the filename
        }
    }
}
