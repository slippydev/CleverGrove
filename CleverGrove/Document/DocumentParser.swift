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
    private let batchSize = 1024  // can submit up to 2048 embedding inputs per request
    private let ai = OpenAICoordinator.shared

    func parse(document: CDDocument, data: Data, dataType: UTType, progressHandler: @escaping (Double) -> Void) async throws -> ParseResult {
        let result = try await withThrowingTaskGroup(of: ParseResult.self) { group -> ParseResult in
            let textChunks = try DocumentDecode.decode(data: data, type: dataType, chunkSize: batchSize)
            let embeddings = try await ai.getEmbeddings(for: textChunks, progressHandler:progressHandler)
            return ParseResult(embeddings: embeddings, textChunks: textChunks)
        }
        return result
    }
}
