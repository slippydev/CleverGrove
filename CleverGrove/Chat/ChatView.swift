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
                            if let query = exchange.query {
                                ChatBubble(position: .right) {
                                    Text(query)
                                }
                            }
                            ChatBubble(position: .left) {
                                Text(exchange.response ?? "")
                            }
                        }
                        .id(index)
                    }
                    if isWaitingForAnswer {
                        if !recentQuery.isEmpty {
                            ChatBubble(position: .right) {
                                Text(recentQuery)
                            }
                        }
                        ChatBubble(position: .left) {
                            TypingIndicator()
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    ChatTextField(string: $userInput, buttonAction: {
                        processChat()
                    })
                        .focused($inputInFocus)
                }
                .disabled(isWaitingForAnswer == true)
                .padding(10)
            }
            .onAppear() {
                scroller.scrollTo(exchangeCount, anchor: .bottom)
                Task {
                   await introduction()
                }
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
    
    func introduction() async {
        isWaitingForAnswer = true
        if let intro = await OpenAICoordinator.shared.introduction(of: expert) {
            response = intro
            saveExchange(query: nil, tokenUsage: 0)
        }
        isWaitingForAnswer = false
    }
    
    func saveExchange(query: String?, tokenUsage: Int) {
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
