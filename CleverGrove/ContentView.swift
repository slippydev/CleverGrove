//
//  ContentView.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import SwiftUI

struct ContentView: View {
    var openAI: OpenAICoordinator
    
    var body: some View {
        ChatView(openAI: openAI)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let openAIKey = KeyStore.key(from: .openAI)
        let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)
        ContentView(openAI: aiCoordinator)
    }
}
