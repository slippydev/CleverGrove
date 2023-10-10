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
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteExpertConfirmation = false
    @State private var isShowingError = false
    @State private var isShowingExternalURL = false
    @State private var errorMessage = ""
    
    @StateObject var expertToDelete = Expert()
    @StateObject var expertToEdit = Expert()
    @StateObject var expertToTrain = Expert()
    @Binding var externalFileURL: URL?
    
    @State var path: [CDExpert] = []
    
    var body: some View {
        NavigationStack(path: $path) {
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
                                                          name: CDExpert.randomName())
                    isShowingEditSheet = true
                    AILogger().log(.showNewExpert)
                } label: {
                    Text("Train a new expert")
                        .foregroundColor(.blue)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.vertical, 10)
                
                List {
                    ForEach(experts, id: \.self) { expert in
                        NavigationLink(value: expert) {
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
                            
                            Button(role: .none) {
                                expertToDelete.expert = expert
                                isShowingDeleteExpertConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                        }
                    }
                }
                .navigationDestination(for: CDExpert.self, destination: { expert in
                    ChatView(expert: expert)
                })
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            }
        }
        .onChange(of: externalFileURL, perform: { newValue in
            if let url = externalFileURL {
                path = .init()
                isShowingExternalURL = true
            }
        })
        .sheet(isPresented: $isShowingExternalURL) {
            FileImportView(url: externalFileURL, expertToTrain: expertToTrain)
                .onDisappear() {
                    // when the file import view is dismissed, check if we have an expert that has been trained.
                    // if so, then auto launch the chat
                    if let expert = expertToTrain.expert {
                        path.append(expert)
                    }
                    cleanupExpertReferences()
                    externalFileURL = nil
                }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditExpertView(expert: expertToEdit.expert ?? CDExpert(context: DataController.shared.managedObjectContext))
                .onDisappear() {
                    cleanupExpertReferences()
                }
        }
        .alert("Delete Expert?", isPresented: $isShowingDeleteExpertConfirmation) {
            Button(role: .destructive) {
                if let expert = expertToDelete.expert {
                    withAnimation {
                        remove(expert: expert)
                    }
                    cleanupExpertReferences()
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
        .alert( Text("Error"), isPresented: $isShowingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .task {
            // Check to see if the embedded expert is installed, and install it if it's missing
            let hasEmbeddedExpert = experts.contains { expert in
                expert.image == "Clever Cat" // FIXME: I need a better process for editing and identifying the embedded expert
            }
            if !hasEmbeddedExpert {
                try? ExpertImporter().installEmbeddedExpert()
            }
        }
    }
    
    func cleanupExpertReferences() {
        expertToEdit.expert = nil
        expertToTrain.expert = nil
        expertToDelete.expert = nil
    }
    
    func remove(expert: CDExpert) {
        DataController.shared.managedObjectContext.delete(expert)
        DataController.shared.save()
    }
    
    func showError(_ text: String) {
        errorMessage = text
        isShowingError = true
    }
}

//struct ExpertListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpertListView()
//    }
//}
