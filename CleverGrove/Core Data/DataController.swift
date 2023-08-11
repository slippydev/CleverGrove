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
