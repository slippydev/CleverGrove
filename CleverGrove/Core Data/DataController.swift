//
//  DataController.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()
    let container = NSPersistentContainer(name: "CleverGrove")
    
    private init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading persistent store: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    var managedObjectContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func fetchDocument(id: UUID) -> CDDocument? {
        let fetchRequest = CDDocument.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? container.viewContext.fetch(fetchRequest).first
    }
    
    func fetchExpert(id: UUID) -> CDExpert? {
        let fetchRequest = CDExpert.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? container.viewContext.fetch(fetchRequest).first
    }
    
}