//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI



@main
struct CleverGroveApp: App {
    @StateObject private var dataController = DataController()
    @State private var aiCoordinator = OpenAICoordinator(key: KeyStore.key(from: .openAI).api_key,
                                                         org: KeyStore.key(from: .openAI).org_key)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environment(\.aiCoordinator, aiCoordinator)
        }
    }
}
