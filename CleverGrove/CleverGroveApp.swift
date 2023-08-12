//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI



@main
struct CleverGroveApp: App {
//    @StateObject private var dataController = DataController()
    
    var body: some Scene {
//        let ai = OpenAICoordinator(key: KeyStore.key(from: .openAI).api_key,
//                                   org: KeyStore.key(from: .openAI).org_key,
//                                   moc: dataController.container.viewContext)
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, DataController.shared.container.viewContext)
//                .environment(\.aiCoordinator, aiCoordinator)
        }
    }
}
