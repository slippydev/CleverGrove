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
    @State private var expertFileURL: URL?
    @State private var isShowingShareSheet = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    @FocusState private var inputInFocus: Bool
    @Environment(\.dismiss) var dismiss
    
    var chatExchanges: [CDChatExchange] {
        expert.chatExchanges() // by default this is limted to 20 exchanges
    }
    
    var exchangeCount: Int {
        chatExchanges.count - 1
    }
    
    func dateTime(from date: Date?) -> String {
        guard let date = date else { return "" }
        if date.timeIntervalSinceNow > -(60) {
            return date.formatted(date: .omitted, time: .shortened)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
    
    var body: some View {
        ScrollViewReader { scroller in
            VStack {
                ScrollView {
                    ForEach(Array(chatExchanges.enumerated()), id:\.element) { index, exchange in
                        VStack {
                            Text(dateTime(from:exchange.timestamp))
                                .font(.caption2)
                                .padding(.top, 15)
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
                            Text(dateTime(from:Date.now))
                                .font(.caption2)
                                .padding(.top, 15)
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
            }
            .onChange(of: isWaitingForAnswer, perform: { _ in
                scroller.scrollTo(exchangeCount, anchor: .bottom)
            })
            .onChange(of: expertFileURL) { _ in  } // weird quantum shit happening here. Need to observe it for expertFileURL to work properly
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                ChatViewHeader(expert: expert)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button() {
                    expertFileURL = exportExpert()
                    isShowingShareSheet = (expertFileURL != nil)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .frame(width: 20, height: 25, alignment: .bottomTrailing)
                        .foregroundColor(.blue)
                }
            }
        }
        .task {
            await introduction()
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let url = expertFileURL {
                ShareSheet(activityItems: [url], completion: shareCompletion)
            }
        }
        .alert( Text("Error"), isPresented: $isShowingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
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
        do {
            (response, relevantChunks) = try await OpenAICoordinator.shared.ask(question: query, expert: expert)
        } catch {
            print(error.localizedDescription)
        }
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
    
    func exportExpert() -> URL? {
        do {
            let exporter = ExpertExporter(expert: expert)
            let url = try exporter.export(to: expert.fileName)
            return url
        } catch {
            showError("Error exporting expert: \(error.localizedDescription)")
            return nil
        }
    }
    
    func shareCompletion(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) {
        // delete the expert file from local storage
        do {
            if let url = expertFileURL {
                try FileManager.default.removeItem(at: url)
            }
            // auto-dismiss the view if the operation was successful, but not if they canceled
            if completed {
                dismiss()
            }
        } catch {
            // FIXME: Log this error once analytics are set up
            print("Removing local expert file after sharing failed.")
        }
    }
    
    func showError(_ text: String) {
        errorMessage = text
        isShowingError = true
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(isWaitingForAnswer: true,
                 recentQuery: "wanna go for lunch?",
                 expert: PreviewSamples.expert)
    }
}
