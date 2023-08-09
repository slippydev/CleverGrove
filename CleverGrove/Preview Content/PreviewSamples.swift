//
//  PreviewSamples.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import Foundation
import SwiftUI

struct PreviewSamples {
    static let docs = [
        DocumentInfo(image: Image(systemName: "doc.plaintext"), fileName: "Hope Inhumanity Rules", status: "Trained"),
        DocumentInfo(image: Image(systemName: "doc.plaintext"), fileName: "Apocalypse World Rules", status: "Trained")
    ]
    static var expert = ExpertProfile(image: "SampleProfile1",
                                      name: "Davy Jones",
                                      description: "This is the description of the expert. They are an expert at something specific, and you can talk to them.",
                                      documents: docs,
                                      openAI: OpenAICoordinator(key: "", org: ""))
    
    static var experts = [
        ExpertProfile(image: "SampleProfile1",
                                          name: "Davy Jones",
                                          description: "Personal recipes expert.",
                                          documents: docs,
                                          openAI: OpenAICoordinator(key: "", org: "")),
        ExpertProfile(image: "SampleProfile2",
                                          name: "Sarah",
                                          description: "Dungeons & Dragons expert.",
                                          documents: docs,
                                          openAI: OpenAICoordinator(key: "", org: "")),
        ExpertProfile(image: "SampleProfile3",
                                          name: "Imran",
                                          description: "Knows everything about my insurance documentation.",
                                          documents: docs,
                                          openAI: OpenAICoordinator(key: "", org: ""))
    ]
}
