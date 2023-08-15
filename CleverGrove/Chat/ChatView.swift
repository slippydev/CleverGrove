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
    @ObservedObject var expert: CDExpert
    
    @FocusState private var inputInFocus: Bool
    
    var body: some View {
        ScrollViewReader { scroller in
            VStack {
                ScrollView {
                    ForEach(0..<model.messages.count, id:\.self) { index in
                        let color = Color(model.positions[index] == BubblePosition.right ? "ChatBubbleRight" : "ChatBubbleLeft")
                        ChatBubble(position: model.positions[index], color: color) {
                            Text(model.messages[index])
                        }
                        .id(index)
                    }
                }
                .onAppear() {
                    scroller.scrollTo(model.messages.count-1, anchor: .bottom)
                }
                .padding(.top)

                HStack {
                    TextEditor(text: $message)
                        .focused($inputInFocus)
                    Button() {
                        processChat()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                    .frame(height: 40, alignment: .trailing)
                    .padding([.trailing], 5)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .frame(height: 40)
                .disabled(isWaitingForAnswer == true)
                .onChange(of: response, perform: { _ in
                    model.addResponse(message: response)
                })
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ChatViewHeader(expert: expert)
            }
        }
    }

    func processChat() {
        inputInFocus = false
        if !message.isEmpty {
            model.addUserChat(message: message)
            let query = message
            message = ""
            Task {
                await ask(message: query)
            }
        }
    }

    func ask(message: String) async {
        isWaitingForAnswer = true
//        if let expert = expert {
            await response = OpenAICoordinator.shared.ask(question: message, expert: expert)
//        }
        isWaitingForAnswer = false
    }
    
}

//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(model: PreviewSamples.chatModel, expert: .constant(PreviewSamples.expert))
//    }
//}
