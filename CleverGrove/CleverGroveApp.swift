//
//  CleverGroveApp.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-06.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct CleverGroveApp: App {
    @State private var url: URL?
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ExpertListView(externalFileURL: $url)
                .environment(\.managedObjectContext, DataController.shared.container.viewContext)
                .onOpenURL { openedURL in
                    AILogger().log(.openURL)
                    url = openedURL
                }
        }
        
    }
}
