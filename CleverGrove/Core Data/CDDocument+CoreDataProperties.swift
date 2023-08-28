//
//  CDDocument+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-28.
//
//

import Foundation
import CoreData


extension CDDocument {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDocument> {
        return NSFetchRequest<CDDocument>(entityName: "CDDocument")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var filetype: String?
    @NSManaged public var id: UUID?
    @NSManaged public var path: String?
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var expert: CDExpert?
    @NSManaged public var textChunks: NSSet?

}

// MARK: Generated accessors for textChunks
extension CDDocument {

    @objc(addTextChunksObject:)
    @NSManaged public func addToTextChunks(_ value: CDTextChunk)

    @objc(removeTextChunksObject:)
    @NSManaged public func removeFromTextChunks(_ value: CDTextChunk)

    @objc(addTextChunks:)
    @NSManaged public func addToTextChunks(_ values: NSSet)

    @objc(removeTextChunks:)
    @NSManaged public func removeFromTextChunks(_ values: NSSet)

}

extension CDDocument : Identifiable {

}
