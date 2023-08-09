//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI

let openAIKey = KeyStore.key(from: .openAI)
//let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)

@main
struct CleverGroveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
