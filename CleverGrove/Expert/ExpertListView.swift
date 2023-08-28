//
//  ExpertListView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

class Expert: ObservableObject {
    @Published var expert: CDExpert?
}

struct ExpertListView: View {
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var experts: FetchedResults<CDExpert>
    
    @State var isShowingEditSheet = false
    @State var isShowingDeleteExpertConfirmation = false
    @StateObject var expertToDelete = Expert()
    @StateObject var expertToEdit = Expert()
    @StateObject var expertToTrain = Expert()
    @Binding var externalFileURL: URL?
    @State var isShowingExternalURL = false
    @State var isAutoShowingExpertChat = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("CleverGrove")
                        .font(.title2)
                        .frame(alignment: .bottomLeading)
                        .padding([.leading], 10)
                }
                
                Button {
                    // Create a new expert to edit
                    expertToEdit.expert = CDExpert.expert(context: DataController.shared.managedObjectContext,
                                                          name: CDExpert.randomName(),
                                                          description: "...details about the area of expertise.")
                    isShowingEditSheet = true
                } label: {
                    Text("Train a new expert")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.vertical, 10)
                
                List {
                    ForEach(experts, id: \.self) { expert in
                        NavigationLink {
                            ChatView(expert: expert)
                        } label: {
                            ExpertSummary(expert: expert)
                        }
                        .swipeActions() {
                            Button {
                                expertToEdit.expert = expert
                                isShowingEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "gearshape.fill")
                            }
                            .tint(.indigo)
                            
                            Button(role: .destructive) {
                                expertToDelete.expert = expert
                                isShowingDeleteExpertConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                if let expert = expertToTrain.expert {
                    NavigationLink(destination: ChatView(expert: expert), isActive: $isAutoShowingExpertChat) { EmptyView() }
                }
            }
        }
        .onChange(of: externalFileURL, perform: { newValue in
            if externalFileURL != nil {
                isShowingExternalURL = true
            }
        })
        .sheet(isPresented: $isShowingExternalURL) {
            FileImportView(url: externalFileURL, expertToTrain: expertToTrain)
                .onDisappear() {
                    // when the file import view is dismissed, check if we have an expert that has been trained.
                    // if so, then auto launch the chat
                    if let _ = expertToTrain.expert {
                        isAutoShowingExpertChat = true
                    }
                    externalFileURL = nil
                }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditExpertView(expert: expertToEdit.expert ?? CDExpert(context: DataController.shared.managedObjectContext))
        }
        .alert("Delete Expert?", isPresented: $isShowingDeleteExpertConfirmation) {
            Button(role: .destructive) {
                if let expert = expertToDelete.expert {
                    expertToDelete.expert = nil
                    remove(expert: expert)
                }
            } label: {
                Text("Delete \(expertToDelete.expert?.name ?? "")")
            }
            Button(role: .cancel) {
                expertToDelete.expert = nil
            } label: {
                Text("Don't Delete")
            }
        }
    }
    
    func remove(expert: CDExpert) {
        print("Deleted")
        DataController.shared.managedObjectContext.delete(expert)
        DataController.shared.save()
    }
}

//struct ExpertListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpertListView()
//    }
//}
