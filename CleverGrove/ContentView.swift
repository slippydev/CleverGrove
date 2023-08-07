//
//  ContentView.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import SwiftUI

struct ContentView: View {
    @State var promptText = ""
    @State var response = "Answer goes here."
    
    var openAI: OpenAICoordinator
    
    var body: some View {
        VStack {
            HStack {
                TextField("Ask a question", text: $promptText)
                Button("Ask") {
                    Task {
                        await ask()
                    }
                }
            }
            Text(response)
        }
        .padding()
    }
    
    func ask() async {
        await response = openAI.ask(question: promptText)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let aiCoordinator = OpenAICoordinator(key: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "",
                                              org: ProcessInfo.processInfo.environment["OPENAI_ORG_KEY"] ?? "")
        ContentView(openAI: aiCoordinator)
    }
}
