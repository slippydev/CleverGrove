//
//  EditExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct EditExpertView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
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
        let newExpert = ExpertProfile(image: "SampleProfile1",
                               name: name,
                               description: description,
                               documents: expert.documents)
        
        // FIXME:
        // Don't just save a new expert to Core Data. This may be
        // an update to an existing Expert.
        let managedExpert = CDExpert.managedExpert(from: newExpert, context: moc)
        do {
            try moc.save()
        } catch {
            print("Error saving to Core data")
        }
    }
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: .constant(PreviewSamples.expert))
    }
}
