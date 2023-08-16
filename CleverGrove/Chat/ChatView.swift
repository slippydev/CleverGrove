//
//  ChatView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI


struct ChatView: View {
    @State var isWaitingForAnswer = false
    @State var recentQuery = ""
    @State private var userInput = ""
    @State private var response = ""
    @State private var relevantChunks = [CDTextChunk]()
    @ObservedObject var expert: CDExpert
    
    @FocusState private var inputInFocus: Bool
    
    var chatExchanges: [CDChatExchange] {
        expert.chatExchanges() // by default this is limted to 20 exchanges
    }
    
    var exchangeCount: Int {
        chatExchanges.count - 1
    }
    
    var body: some View {
        ScrollViewReader { scroller in
            VStack {
                ScrollView {
                    ForEach(Array(chatExchanges.enumerated()), id:\.element) { index, exchange in
                        VStack {
                            ChatBubble(position: .right, color: Color("ChatBubbleRight")) {
                                Text(exchange.query ?? "")
                            }
                            ChatBubble(position: .left, color: Color("ChatBubbleLeft")) {
                                Text(exchange.response ?? "")
                            }
                        }
                        .id(index)
                    }
                    if isWaitingForAnswer {
                        ChatBubble(position: .right, color: Color("ChatBubbleRight")) {
                            Text(recentQuery)
                        }
                        ChatBubble(position: .left, color: Color("ChatBubbleLeft")) {
                            TypingIndicator()
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    TextEditor(text: $userInput)
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
                .padding([.horizontal], 10)
            }
            .onAppear() {
                scroller.scrollTo(exchangeCount, anchor: .bottom)
            }
            .onChange(of: isWaitingForAnswer, perform: { _ in
                scroller.scrollTo(exchangeCount, anchor: .bottom)
            })
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ChatViewHeader(expert: expert)
            }
        }
    }

    func processChat() {
        inputInFocus = false
        if !userInput.isEmpty {
            recentQuery = userInput
            userInput = ""
            Task {
                await ask(query: recentQuery)
            }
        }
    }

    func ask(query: String) async {
        isWaitingForAnswer = true
        await (response, relevantChunks) = OpenAICoordinator.shared.ask(question: query, expert: expert)
        saveExchange(query: query, tokenUsage: 0)
        isWaitingForAnswer = false
    }
    
    func saveExchange(query: String, tokenUsage: Int) {
        let exchange = CDChatExchange.chatExchange(context: DataController.shared.managedObjectContext,
                                                   query: query,
                                                   response: response,
                                                   date: Date.now,
                                                   tokenUsage: tokenUsage)
        expert.addToChatExchanges(exchange)
        exchange.addToTextchunks(NSSet(array: relevantChunks))
        DataController.shared.save()
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(isWaitingForAnswer: true,
                 recentQuery: "wanna go for lunch?",
                 expert: PreviewSamples.expert)
    }
}
