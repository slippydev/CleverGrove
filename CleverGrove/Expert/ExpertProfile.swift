//
//  ExpertProfile.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import Foundation

struct ExpertProfile: Identifiable {
    var id = UUID()
    let image: String?
    let name: String
    let description: String
    var documents = [DocumentInfo]()
    var openAI: OpenAICoordinator
    
    init(id: UUID = UUID(), image: String?, name: String, description: String, documents: [DocumentInfo] = [DocumentInfo](), openAI: OpenAICoordinator) {
        self.id = id
        self.image = image
        self.name = name
        self.description = description
        self.documents = documents
        self.openAI = openAI
    }
}
