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
    
    init(id: UUID = UUID(), image: String?, name: String, description: String, documents: [DocumentInfo] = [DocumentInfo]()) {
        self.id = id
        self.image = image
        self.name = name
        self.description = description
        self.documents = documents
    }
    
    static func emptyExpert() -> ExpertProfile {
        return ExpertProfile(image: nil, name: "Name Your Expert", description: "Describe your expert")
    }
}
