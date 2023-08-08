//
//  ContentView.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import SwiftUI

struct ContentView: View {
    var openAI: OpenAICoordinator
    let experts = [ExpertProfile(image: "SampleProfile1", name: "George", description: "Personal recipes expert.", openAI: aiCoordinator),
                   ExpertProfile(image: "SampleProfile2", name: "Sarah", description: "Dungeons & Dragons expert.", openAI: aiCoordinator),
                   ExpertProfile(image: "SampleProfile3", name: "Imran", description: "Knows everything about my insurance documentation.", openAI: aiCoordinator)]
    
    var body: some View {
        
        ExpertListView(experts: experts)
//        ChatView(openAI: openAI)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let openAIKey = KeyStore.key(from: .openAI)
        let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)
        ContentView(openAI: aiCoordinator)
    }
}
