//
//  CDTextChunk+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-16.
//
//

import Foundation
import CoreData


extension CDTextChunk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTextChunk> {
        return NSFetchRequest<CDTextChunk>(entityName: "CDTextChunk")
    }

    @NSManaged public var embedding: String?
    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var document: CDDocument?
    @NSManaged public var expert: CDExpert?
    @NSManaged public var chatExchanges: NSSet?

}

// MARK: Generated accessors for chatExchanges
extension CDTextChunk {

    @objc(addChatExchangesObject:)
    @NSManaged public func addToChatExchanges(_ value: CDChatExchange)

    @objc(removeChatExchangesObject:)
    @NSManaged public func removeFromChatExchanges(_ value: CDChatExchange)

    @objc(addChatExchanges:)
    @NSManaged public func addToChatExchanges(_ values: NSSet)

    @objc(removeChatExchanges:)
    @NSManaged public func removeFromChatExchanges(_ values: NSSet)

}

extension CDTextChunk : Identifiable {

}
