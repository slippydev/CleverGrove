//
//  CDExpert+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
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
            let managedDoc = CDDocument(context: context)
            managedDoc.id = doc.id
            managedDoc.fileName = doc.fileName
            managedDoc.path = doc.path
            managedDoc.status = doc.status.rawValue
            managedDoc.filetype = doc.fileType.rawValue
        }
        return managedExpert
    }
    
    func expertProfile() -> ExpertProfile {
        return ExpertProfile(image: image, name: name ?? "", description: desc ?? "")
    }
    
    var documentsArray: [DocumentInfo] {
        let set = documents as? Set<CDDocument> ?? []
        return set.map { managedDocument in
            CDDocument.document(from: managedDocument)
        }
    }
}
