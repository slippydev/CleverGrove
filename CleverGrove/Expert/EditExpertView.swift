//
//  EditExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct EditExpertView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expert: ExpertProfile
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var image: Image = Image(systemName: "questionmark.square.dashed")
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center) {
                        ZStack {
                            ExpertProfileImage(image: image, geo: geometry)
                                .colorMultiply(.gray)
                                .saturation(0.5)
                            SelectionBox(geo: geometry)
                        }
                        Divider()
                        TextField(expert.name, text: $name)
                            .font(.title.bold())
                            .padding(.bottom, 5)
                            .multilineTextAlignment(.center)
                        
                        TextEditor(text: $description)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                        
                    }
                    Divider()
                    HStack {
                        Text("Training Documents")
                            .font(.title2)
                            .padding([.bottom, .top, .leading], 10)
                            .foregroundColor(Color("Primary"))
                        Spacer()
                        Button() {
                            
                        } label: {
                            Image(systemName: "plus.square")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(10)
                        }
                    }
                    ScrollView() {
                        VStack(alignment: .leading) {
                            ForEach(expert.documents) { document in
                                NavigationLink {
                                    // Link to document
                                } label: {
                                    DocumentCapsule(info: document)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .toolbar {
                Spacer()
                Button() {
                    saveChanges()
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
            .onAppear() {
                description = expert.description
                name = expert.name
                image = Image(expert.image ?? "")
            }
        }
    }
    
    func saveChanges() {
        expert = ExpertProfile(image: nil,
                               name: name,
                               description: description,
                               documents: expert.documents,
                               openAI: expert.openAI)
        
    }
}

struct EditExpertView_Previews: PreviewProvider {
    static let docs = [
        DocumentInfo(image: Image(systemName: "doc.plaintext"), fileName: "Hope Inhumanity Rules", status: "Trained"),
        DocumentInfo(image: Image(systemName: "doc.plaintext"), fileName: "Apocalypse World Rules", status: "Trained")
    ]
    static var expert = ExpertProfile(image: "SampleProfile1",
                                      name: "Davy Jones",
                                      description: "This is the description of the expert. They are an expert at something specific, and you can talk to them.",
                                      documents: docs,
                                      openAI: OpenAICoordinator(key: "", org: ""))
    
    
    
    static var previews: some View {
        EditExpertView(expert: .constant(expert))
    }
}
