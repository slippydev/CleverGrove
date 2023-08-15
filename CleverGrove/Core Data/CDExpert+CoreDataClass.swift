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
    
    static func expert(context: NSManagedObjectContext, name: String, description: String) -> CDExpert {
        let expert = CDExpert(context: context)
        expert.id = UUID()
        expert.name = name
        expert.desc = description
        return expert
    }
    
    var documentsAsArray : [CDDocument] {
        let set = documents as? Set<CDDocument> ?? []
        return set.map { $0 }
    }
}
