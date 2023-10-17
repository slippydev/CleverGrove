//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI

@main
struct CleverGroveApp: App {
    @State private var url: URL?
    
    var body: some Scene {
        WindowGroup {
            ExpertListView(externalFileURL: $url)
                .environment(\.managedObjectContext, DataController.shared.container.viewContext)
                .onOpenURL { openedURL in
                    CGLogger().log(.openURL)
                    url = openedURL
                }
        }
        
    }
}
