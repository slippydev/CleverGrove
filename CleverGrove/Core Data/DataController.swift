//
//  DataController.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "CleverGrove")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading persistent store: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
}
