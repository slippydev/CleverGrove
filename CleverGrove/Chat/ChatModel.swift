//
//  ChatModel.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import Foundation

class ChatModel: ObservableObject {
    @Published var messages : [String] = []
    @Published var positions : [BubblePosition] = []
    @Published var position = BubblePosition.right
    
    func addUserChat(message: String) {
        position = .right // user messages are always on the right side
        positions.append(position)
        messages.append(message)
    }
    
    func addResponse(message: String) {
        position = .left // response messages are always on the left side
        positions.append(position)
        messages.append(message)
    }
    
    func mostRecentMessage() -> String {
        guard messages.count > 0 else { return "" }
        return messages[messages.count-1]
    }
}
