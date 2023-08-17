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
    
    var textChunksAsArray: [CDTextChunk] {
        let set = textChunks as? Set<CDTextChunk> ?? []
        return set.map { $0 }
    }
    
    func chatExchanges(in range: Range<Int> = 0..<20) -> [CDChatExchange] {
        let set = chatExchanges as? Set<CDChatExchange> ?? []
        let sortedArray = set.sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now }
        
        // Get a safe range so we don't get an out of bounds error
        let validLowerBound = max(range.lowerBound, 0)
        let validUpperBound = min(range.upperBound, sortedArray.count)
        let validRange = validLowerBound..<validUpperBound
        
        // We want the most recent 20 exchanges. The sorted list ends with the most recent first. So if we slice it we'll lose the most recent.
        // So we reverse it, then slice the oldest entries, then reverse it again to get it back into date sorted order.
        let slicedArray = sortedArray.reversed()[validRange].reversed()
        return Array(slicedArray)
    }
    
    var chatExchangesAsArray: [CDChatExchange] {
        let set = chatExchanges as? Set<CDChatExchange> ?? []
        let sortedArray = set.sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now }
        return sortedArray
    }
    
    func findTextChunks(with texts: [String]) -> [CDTextChunk] {
        guard let textChunks = textChunks else { return [CDTextChunk]() }
        let matchingChunks = textChunks.filter { chunk in
            return texts.contains((chunk as! CDTextChunk).text ?? "")
        }
        return matchingChunks as! [CDTextChunk]
    }
}
