//
//  ChatView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var model = ChatModel()
    @State private var isWaitingForAnswer = false
    @State private var message = ""
    @State private var response = ""
    
    var openAI: OpenAICoordinator
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                CustomScrollView(scrollToEnd: true) {
                    LazyVStack {
                        ForEach(0..<model.messages.count, id:\.self) { index in
                            let color = Color(model.positions[index] == BubblePosition.right ? "ChatBubbleRight" : "ChatBubbleLeft")
                            ChatBubble(position: model.positions[index], color: color) {
                                Text(model.messages[index])
                            }
                        }
                    }
                }
                .padding(.top)
                
                HStack {
                    ZStack {
                        TextEditor(text: $message)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(.gray)
                    }
                    .frame(height: 50)
                    
                    Button() {
                        if !message.isEmpty {
                            model.addUserChat(message: message)
                            let query = message
                            message = ""
                            Task {
                                await ask(message: query)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    .frame(height: 50)
                }
                .disabled(isWaitingForAnswer == true)
                .onChange(of: response, perform: { _ in
                    model.addResponse(message: response)
                })
                .padding()
            }
        }
    }
    
    func ask(message: String) async {
        isWaitingForAnswer = true
        await response = openAI.ask(question: message)
        isWaitingForAnswer = false
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let openAIKey = KeyStore.key(from: .openAI)
        let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)

        ChatView(openAI: aiCoordinator)
    }
}
