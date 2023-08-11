//
//  CDTextChunk+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//
//

import Foundation
import CoreData


extension CDTextChunk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTextChunk> {
        return NSFetchRequest<CDTextChunk>(entityName: "CDTextChunk")
    }

    @NSManaged public var text: String?
    @NSManaged public var embedding: String?
    @NSManaged public var id: UUID?
    @NSManaged public var expert: CDExpert?
    @NSManaged public var document: CDDocument?

}

extension CDTextChunk : Identifiable {

}
