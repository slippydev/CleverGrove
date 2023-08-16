//
//  CDChatExchange+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-16.
//
//

import Foundation
import CoreData


extension CDChatExchange {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatExchange> {
        return NSFetchRequest<CDChatExchange>(entityName: "CDChatExchange")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var query: String?
    @NSManaged public var response: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var tokenUsage: Int16
    @NSManaged public var expert: CDExpert?
    @NSManaged public var textchunks: NSSet?

}

// MARK: Generated accessors for textchunks
extension CDChatExchange {

    @objc(addTextchunksObject:)
    @NSManaged public func addToTextchunks(_ value: CDTextChunk)

    @objc(removeTextchunksObject:)
    @NSManaged public func removeFromTextchunks(_ value: CDTextChunk)

    @objc(addTextchunks:)
    @NSManaged public func addToTextchunks(_ values: NSSet)

    @objc(removeTextchunks:)
    @NSManaged public func removeFromTextchunks(_ values: NSSet)

}

extension CDChatExchange : Identifiable {

}
