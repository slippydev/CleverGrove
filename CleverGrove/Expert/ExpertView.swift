//
//  ExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct ExpertView: View {
    @Binding var expert: ExpertProfile
    @State private var showingEditView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        ExpertProfileImage(image: Image(expert.image ?? ""), geo: geometry)
                        Divider()
                        Text(expert.name)
                            .font(.title.bold())
                            .padding(.bottom, 5)
                        Text(expert.description)
                            .padding(.horizontal, 20)
                    }
                    Divider()
                    Text("Training Documents")
                        .font(.title2)
                        .padding([.bottom, .top], 10)
                        .foregroundColor(Color("Primary"))
                    ScrollView() {
                        VStack(alignment: .leading) {
                            ForEach($expert.documents) { $document in
                                NavigationLink {
                                    // Link to document
                                } label: {
                                    DocumentCapsule(document: $document)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button() {
                        showingEditView = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditExpertView(expert: expert)
            }
        }
    }
}

struct ExpertView_Previews: PreviewProvider {
    static var previews: some View {
        ExpertView(expert: .constant(PreviewSamples.expert))
    }
}
