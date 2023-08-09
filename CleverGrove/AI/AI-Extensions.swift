//
//  AI-Extensions.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-08.
//

import Foundation

extension JSONDecoder {
    static var openAIDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .millisecondsSince1970

        return decoder
    }
}

extension JSONEncoder {
    static var openAIEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
