//
//  TextChunkTests.swift
//  CleverGroveTests
//
//  Created by Derek Gour on 2023-08-11.
//

import XCTest
@testable import CleverGrove

final class TextChunkTests: XCTestCase {

    func testEmbeddingAsString() {
        let embedding = [0.938383, -0.363763, -2.181818, 0.0, 3.1010101]
        let textChunk = TextChunk(text: "Random Text", embedding: embedding, document: PreviewSamples.document, expert: PreviewSamples.expert)
        let embeddingText = textChunk.embeddingAsString
        let expectedText = "0.938383, -0.363763, -2.181818, 0.0, 3.1010101"
        XCTAssertEqual(embeddingText, expectedText)
    }

    func testEmbeddingFromString() {
        let embeddingText = "0.938383, -0.363763, -2.181818, 0.0, 3.1010101"
        let embedding = TextChunk.embedding(from: embeddingText)
        let expectedEmbedding = [0.938383, -0.363763, -2.181818, 0.0, 3.1010101]
        XCTAssertEqual(embedding, expectedEmbedding)
    }
}
