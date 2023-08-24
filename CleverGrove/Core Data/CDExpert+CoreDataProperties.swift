//
//  CDExpert+CoreDataProperties.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-24.
//
//

import Foundation
import CoreData


extension CDExpert {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDExpert> {
        return NSFetchRequest<CDExpert>(entityName: "CDExpert")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var personality: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var chatExchanges: NSSet?
    @NSManaged public var documents: NSSet?
    @NSManaged public var textChunks: NSSet?

}

// MARK: Generated accessors for chatExchanges
extension CDExpert {

    @objc(addChatExchangesObject:)
    @NSManaged public func addToChatExchanges(_ value: CDChatExchange)

    @objc(removeChatExchangesObject:)
    @NSManaged public func removeFromChatExchanges(_ value: CDChatExchange)

    @objc(addChatExchanges:)
    @NSManaged public func addToChatExchanges(_ values: NSSet)

    @objc(removeChatExchanges:)
    @NSManaged public func removeFromChatExchanges(_ values: NSSet)

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

// MARK: Generated accessors for textChunks
extension CDExpert {

    @objc(addTextChunksObject:)
    @NSManaged public func addToTextChunks(_ value: CDTextChunk)

    @objc(removeTextChunksObject:)
    @NSManaged public func removeFromTextChunks(_ value: CDTextChunk)

    @objc(addTextChunks:)
    @NSManaged public func addToTextChunks(_ values: NSSet)

    @objc(removeTextChunks:)
    @NSManaged public func removeFromTextChunks(_ values: NSSet)

}

extension CDExpert : Identifiable {

}
