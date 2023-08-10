//
//  PreviewSamples.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import Foundation
import SwiftUI

struct PreviewSamples {
    static let document = DocumentInfo(fileType: .text, fileName: "HopeInhumanityRules", path: "file:///somewhere/Documents/HopeInhumanityRules.txt", status: .untrained)
    
    static let documents = [
        DocumentInfo(fileType: .text, fileName: "ApolalypseWorldRules", path: "file:///somewhere/Documents/ApolalypseWorldRules.txt", status: .trained),
        DocumentInfo(fileType: .text, fileName: "HopeInhumanityRules", path: "file:///somewhere/Documents/HopeInhumanityRules.txt", status: .untrained)
    ]
    
    static var expert = ExpertProfile(image: "SampleProfile1",
                                      name: "Davy Jones",
                                      description: "This is the description of the expert. They are an expert at something specific, and you can talk to them.",
                                      documents: documents)
    
    static var experts = [
        ExpertProfile(image: "SampleProfile1",
                                          name: "Davy Jones",
                                          description: "Personal recipes expert.",
                                          documents: documents),
        ExpertProfile(image: "SampleProfile2",
                                          name: "Sarah",
                                          description: "Dungeons & Dragons expert.",
                                          documents: documents),
        ExpertProfile(image: "SampleProfile3",
                                          name: "Imran",
                                          description: "Knows everything about my insurance documentation.",
                                          documents: documents)
    ]
    
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
}
