//
//  CDExpert+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//
//

import Foundation
import CoreData


extension CDExpert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDExpert> {
        return NSFetchRequest<CDExpert>(entityName: "CDExpert")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var documents: NSSet?

}

// MARK: Generated accessors for documents
extension CDExpert {

    @objc(addDocumentsObject:)
    @NSManaged public func addToDocuments(_ value: CDDocument)

    @objc(removeDocumentsObject:)
    @NSManaged public func removeFromDocuments(_ value: CDDocument)

    @objc(addDocuments:)
    @NSManaged public func addToDocuments(_ values: NSSet)

    @objc(removeDocuments:)
    @NSManaged public func removeFromDocuments(_ values: NSSet)

}

extension CDExpert : Identifiable {

}
