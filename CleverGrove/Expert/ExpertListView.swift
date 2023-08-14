//
//  ExpertListView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertListView: View {
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var experts: FetchedResults<CDExpert>
    
    @State var isShowingEditSheet = false
    @StateObject var expertToEdit = ExpertToEdit()
    
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
                    //
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
                                // Remove the expert from Core Data
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditExpertView(expert: expertToEdit.expert ?? CDExpert(context: DataController.shared.managedObjectContext))
        }
    }
}

struct ExpertListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpertListView()
    }
}
