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
