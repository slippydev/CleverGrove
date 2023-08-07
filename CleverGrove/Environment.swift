//
//  Environment.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import SwiftUI

private struct OpenAIAPIKey: EnvironmentKey {
    static let defaultValue = ""
}

private struct OpenAIOrgKey: EnvironmentKey {
    static let defaultValue = ""
}

extension EnvironmentValues {
    var openAIKey: String {
        get { self[OpenAIAPIKey.self] }
        set { self[OpenAIAPIKey.self] = newValue }
    }
    
    var openAIOrgKey: String {
        get { self[OpenAIOrgKey.self] }
        set { self[OpenAIOrgKey.self] = newValue }
    }
}
