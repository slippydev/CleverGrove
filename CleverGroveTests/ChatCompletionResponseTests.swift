//
//  ChatCompletionResponseTests.swift
//  CleverGroveTests
//
//  Created by Derek Gour on 2023-10-11.
//

import XCTest
@testable import CleverGrove

/*
{
    "choices": [
        {
            "finish_reason": "length",
            "index": 0,
            "logprobs": null,
            "text": "Let Your Sweet Tooth Run Wild at Our Creamy Ice Cream Shack"
        }
    ],
    "created": 1683130927,
    "id": "cmpl-7C9Wxi9Du4j1lQjdjhxBlO22M61LD",
    "model": "gpt-3.5-turbo-instruct",
    "object": "text_completion",
    "usage": {
        "completion_tokens": 16,
        "prompt_tokens": 10,
        "total_tokens": 26
    }
}
*/
final class ChatCompletionResponseTests: XCTestCase {

    func testDecodeChatCompletionResponse() throws {
        // Read in a json file represeting Chat Completions API response from https://platform.openai.com/docs/guides/gpt/completions-api
        // Decode the json into a valid ChatCompletionResponse object
        
        let url = Bundle(for: Self.self).url(forResource: "ChatCompletionResponse", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        guard let response = ChatCompletionResponse.decode(data: data!) as? ChatCompletionResponse else {
            XCTAssertFalse(false)
            return
        }
        XCTAssertEqual(response.model, "gpt-3.5-turbo-instruct")
        XCTAssertEqual(response.created, 1683130927)
        XCTAssertEqual(response.id, "cmpl-7C9Wxi9Du4j1lQjdjhxBlO22M61LD")
        XCTAssertEqual(response.object, "text_completion")
        XCTAssertEqual(response.usage?.completionTokens, 16)
        XCTAssertEqual(response.usage?.promptTokens, 10)
        XCTAssertEqual(response.usage?.totalTokens, 26)
        XCTAssertEqual(response.choices.first?.finishReason, "length")
        XCTAssertEqual(response.choices.first?.index, 0)
        XCTAssertEqual(response.choices.first?.logprobs, nil)
        XCTAssertEqual(response.choices.first?.text, "Let Your Sweet Tooth Run Wild at Our Creamy Ice Cream Shack")
    }

}
