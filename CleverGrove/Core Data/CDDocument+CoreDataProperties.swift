//
//  CDDocument+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//
//

import Foundation
import CoreData


extension CDDocument {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDocument> {
        return NSFetchRequest<CDDocument>(entityName: "CDDocument")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var filetype: String?
    @NSManaged public var fileName: String?
    @NSManaged public var path: String?
    @NSManaged public var status: String?
    @NSManaged public var expert: CDExpert?

}

extension CDDocument : Identifiable {

}
