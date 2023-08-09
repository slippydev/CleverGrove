//
//  CleverGroveTests.swift
//  CleverGroveTests
//
//  Created by Derek Gour on 2023-08-06.
//

import XCTest
@testable import CleverGrove

final class CleverGroveTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodeEmbeddingsResponse() throws {
        // Read in a json file represeting Embeddings API response from https://platform.openai.com/docs/api-reference/embeddings
        // Decode the json into a valid EmbeddingsResponse object
        
        let url = Bundle(for: Self.self).url(forResource: "EmbeddingResponse", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        let response = EmbeddingsResponse.decode(data: data!)
        XCTAssertNotNil(response)
        XCTAssertEqual(response!.model, "text-embedding-ada-002")
        XCTAssertEqual(response!.object, "list")
        XCTAssertEqual(response!.usage.promptTokens, 8)
        XCTAssertEqual(response!.usage.totalTokens, 8)
        let embeddings = response!.data.first!
        XCTAssertEqual(embeddings.embedding, response!.embedding)
        XCTAssertEqual(embeddings.object, "embedding")
        XCTAssertEqual(embeddings.index, 0)
        XCTAssertTrue(embeddings.embedding.count == 8)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
