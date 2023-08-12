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
    @State private var showingExpertView = false
    @Binding var expert: ExpertProfile
    @State var managedExpert: CDExpert?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { scroller in
                VStack {
                    HStack {
                        ExpertSummary(expert: expert)
                        Button {
                            showingExpertView = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .topTrailing)
                                .padding(.horizontal)
                        }
                    }
                    
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
                .sheet(isPresented: $showingExpertView) {
                    //                dismiss()
                    ExpertView(expert: $expert)
                }
            }
        }
        .onAppear() {
            let fetchRequest = CDExpert.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", expert.id as CVarArg)
            let moc = DataController.shared.managedObjectContext
            managedExpert = try? moc.fetch(fetchRequest).first
        }
    }
    
    func ask(message: String) async {
        isWaitingForAnswer = true
        if let managedExpert = managedExpert {
            let ai = OpenAICoordinator.shared
            await response = ai.ask(question: message, expert: managedExpert)
        }
        isWaitingForAnswer = false
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(model: PreviewSamples.chatModel, expert: .constant(PreviewSamples.expert))
    }
}
