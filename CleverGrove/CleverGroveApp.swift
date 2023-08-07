//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI

let aiCoordinator = OpenAICoordinator(key: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
                                      org: ProcessInfo.processInfo.environment["OPENAI_ORG_KEY"] ?? "")


@main
struct CleverGroveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(openAI: aiCoordinator)
        }
    }
}
