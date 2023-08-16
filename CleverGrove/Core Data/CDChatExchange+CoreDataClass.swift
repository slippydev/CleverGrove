//
//  CDChatExchange+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-16.
//
//

import Foundation
import CoreData

@objc(CDChatExchange)
public class CDChatExchange: NSManagedObject {

    static func chatExchange(context: NSManagedObjectContext, query: String, response: String, date: Date, tokenUsage: Int) -> CDChatExchange {
        let chat = CDChatExchange(context: context)
        chat.id = UUID()
        chat.query = query
        chat.response = response
        chat.timestamp = date
        chat.tokenUsage = Int16(tokenUsage)
        return chat
    }
}
