//
//  CDExpert+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//
//

import Foundation
import CoreData

@objc(CDExpert)
public class CDExpert: NSManagedObject {
    static func managedExpert(from expert: ExpertProfile, context: NSManagedObjectContext) -> CDExpert {
        let managedExpert = CDExpert(context: context)
        managedExpert.image = expert.image
        managedExpert.name = expert.name
        managedExpert.desc = expert.description
        managedExpert.id = expert.id
        for doc in expert.documents {
            let managedDoc = CDDocument.managedDocument(from: doc, context: context)
            managedDoc.expert = managedExpert
            managedExpert.addToDocuments(managedDoc)
        }
        
        return managedExpert
    }
    
    func expertProfile() -> ExpertProfile {
        return ExpertProfile(id: id ?? UUID(),
                             image: image,
                             name: name ?? "",
                             description: desc ?? "",
                             documents: documentsArray)
    }
    
    var documentsArray: [DocumentInfo] {
        let set = documents as? Set<CDDocument> ?? []
        return set.map { managedDocument in
            managedDocument.document()
        }
    }
}
