//
//  ChatCompletionResponseTests.swift
//  CleverGroveTests
//
//  Created by Derek Gour on 2023-10-11.
//

import XCTest
@testable import CleverGrove

final class ChatCompletionResponseTests: XCTestCase {

    func testDecodeChatCompletionResponse() throws {
        // Read in a json file represeting Chat Completions API response from https://platform.openai.com/docs/guides/gpt/chat-completions-api
        // Decode the json into a valid ChatCompletionResponse object
        
        let url = Bundle(for: Self.self).url(forResource: "ChatCompletionResponse", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        guard let response = ChatCompletionResponse.decode(data: data!) as? ChatCompletionResponse else {
            XCTAssertFalse(false)
            return
        }
        XCTAssertEqual(response.model, "gpt-3.5-turbo-0613")
        XCTAssertEqual(response.created, 1677664795)
        XCTAssertEqual(response.id, "chatcmpl-7QyqpwdfhqwajicIEznoc6Q47XAyW")
        XCTAssertEqual(response.object, "chat.completion")
        XCTAssertEqual(response.usage?.completionTokens, 17)
        XCTAssertEqual(response.usage?.promptTokens, 57)
        XCTAssertEqual(response.usage?.totalTokens, 74)
        XCTAssertEqual(response.choices.first?.finishReason, "stop")
        XCTAssertEqual(response.choices.first?.index, 0)
        XCTAssertEqual(response.message?.content, "The 2020 World Series was played in Texas at Globe Life Field in Arlington.")
    }

}
