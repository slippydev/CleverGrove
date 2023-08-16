//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI



@main
struct CleverGroveApp: App {

    var body: some Scene {
        WindowGroup {
            ExpertListView()
                .environment(\.managedObjectContext, DataController.shared.container.viewContext)
        }
    }
}
