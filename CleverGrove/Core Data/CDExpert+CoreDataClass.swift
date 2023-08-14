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
    
    var documentsArray: [DocumentInfo] {
        let set = documents as? Set<CDDocument> ?? []
        return set.map { managedDocument in
            managedDocument.document()
        }
    }
    
    var documentsAsArray : [CDDocument] {
        let set = documents as? Set<CDDocument> ?? []
        return set.map { $0 }
    }
}
