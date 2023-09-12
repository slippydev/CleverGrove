//
//  PreviewSamples.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import Foundation
import SwiftUI

struct PreviewSamples {
    
    static var chatExchanges: [CDChatExchange] {
        let moc = DataController.shared.managedObjectContext
//        let date1 = try? Date("2023‐08‐16T19:16:09Z", strategy: .iso8601)
//        let date2 = try? Date("2023‐08‐16T20:19:09Z", strategy: .iso8601)
        return [CDChatExchange.chatExchange(context: moc, query: "hello", response: "Hey how are you?", date: Date.now, tokenUsage: 0),
                CDChatExchange.chatExchange(context: moc, query: "you up?", response: "Nah dog, I'm dead asleep", date: Date.now, tokenUsage: 0)]
    }
    
    static var documentTraining: CDDocument {
        CDDocument.document(context: DataController.shared.managedObjectContext, fileURL: URL(string: "file://test/me/myfile.txt")!, fileType: .text, status: .training)
    }
    
    static var documentTrained: CDDocument {
        CDDocument.document(context: DataController.shared.managedObjectContext, fileURL: URL(string: "file://test/me/myfile.txt")!, fileType: .text, status: .trained)
    }
    
    static var documents: [CDDocument] {
        let moc = DataController.shared.managedObjectContext
        return [CDDocument.document(context: moc, fileURL: URL(string: "file://test/me/myfile.txt")!, fileType: .text, status: .trained),
                CDDocument.document(context: moc, fileURL: URL(string: "file://test/me/myfile.pdf")!, fileType: .pdf, status: .trained),
                CDDocument.document(context: moc, fileURL: URL(string: "file://test/me/coolfile.txt")!, fileType: .text, status: .training)]
    }
    
    static var expert: CDExpert {
        let expert = CDExpert(context: DataController.shared.managedObjectContext)
        expert.id = UUID()
        expert.name = "Bobby Bo Body"
        expert.expertise = "Bobby knows all"
        expert.image = "Quinn"
        expert.addToDocuments(PreviewSamples.documentTrained)
        expert.addToDocuments(PreviewSamples.documentTraining)
        expert.addToChatExchanges(NSSet(array: PreviewSamples.chatExchanges))
        return expert
    }
}
