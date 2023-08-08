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
    var openAI: OpenAICoordinator
}
