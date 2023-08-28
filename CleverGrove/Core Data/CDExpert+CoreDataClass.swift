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
        expert.image = name
        expert.desc = description
        return expert
    }
    
    var documentsAsArray : [CDDocument] {
        let set = documents as? Set<CDDocument> ?? []
        let array = set.map { $0 }
        let sortedArray = array.sorted { $0.fileName ?? "" < $1.fileName ?? "" }
        return sortedArray
    }
    
    var textChunksAsArray: [CDTextChunk] {
        let set = textChunks as? Set<CDTextChunk> ?? []
        return set.map { $0 }
    }
    
    var trainingDocumentTitles: [String] {
        var titles = [String]()
        if let documents = documents {
            for document in documents {
                if let title = (document as AnyObject).title ?? "" {
                    titles.append(title)
                }
            }
        }
        return titles
    }
    
    var communicationStyle: CommunicationStyle {
        CommunicationStyle(rawValue: personality ?? "") ?? .formal
    }
    
    func mostRecentChatExchange() -> CDChatExchange? {
        // The sorted list ends with the most recent first. So if we need the last entry to get the most recent
        let set = chatExchanges as? Set<CDChatExchange> ?? []
        let sortedArray = set.sorted { $0.timestamp ?? Date.now < $1.timestamp ?? Date.now }
        return sortedArray.last
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
    
    func pastQueries(in range: Range<Int>) -> String {
        var pastQueries = String()
        for exchange in chatExchanges(in:0..<5) {
            if let pastQuery = exchange.query {
                pastQueries += "\n\(pastQuery)"
            }
        }
        return pastQueries
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
    
    func updatedSince(date: Date) -> Bool {
        guard let updatedDate = lastUpdated else { return false }
        return updatedDate > date
    }
    
    static func randomName() -> String {
        let index = Int.random(in: 0..<randomNames.count)
        return randomNames[index]
    }
    
}
