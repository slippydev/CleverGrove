//
//  PreviewSamples.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import Foundation
import SwiftUI

struct PreviewSamples {
    
    static var chatModel: ChatModel {
        let model = ChatModel()
        model.addUserChat(message: "hello")
        model.addResponse(message: "How are you?")
        model.addUserChat(message: "you up?")
        model.addUserChat(message: "nah bruh, I'm dead asleep")
        model.addResponse(message: "cool cool")
        model.addUserChat(message: "wyd")
        model.addResponse(message: "not much, just chillin, having a bud")
        model.addUserChat(message: "waaaasssuuuuup!")
        model.addResponse(message: "bruh")
        model.addUserChat(message: "wut?")
        model.addResponse(message: "dude that's so 20 years ago what are you 76 years old?")
        return model
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
        expert.desc = "Bobby knows all"
        expert.image = "SampleProfile3"
        expert.addToDocuments(PreviewSamples.documentTrained)
        // FIXME: Add Text chunks.
        return expert
    }
}
