//
//  EditExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentList: View {
    @Binding var documents: [DocumentInfo]
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                ForEach(documents) { document in
                    NavigationLink {
                        // Link to document
                    } label: {
                        DocumentCapsule(info: document)
                    }
                }
            }
        }
    }
}

struct EditExpertView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    @State var expert: ExpertProfile
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var image: Image = Image(systemName: "questionmark.square.dashed")
    @State private var isShowingFilePicker = false
    @State private var fileData: Data?
    @State private var fileURL: URL?
    
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
                            isShowingFilePicker = true
                        } label: {
                            Image(systemName: "plus.square")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(10)
                        }
                    }
                    DocumentList(documents: $expert.documents)
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
            .sheet(isPresented: $isShowingFilePicker) {
                FilePicker(fileData: $fileData, fileURL: $fileURL)
            }
            .onChange(of: fileData) { newValue in
                addDocument()
            }
        }
    }
    
    func addDocument() {
        guard let path = fileURL?.absoluteString, let fileName = fileURL?.lastPathComponent else {
            print("Error reading selected file URL")
            return
        }
        let newDoc = DocumentInfo(fileType: .text, fileName: fileName, path: path, status: .untrained)
        expert.documents.append(newDoc)
        // The new document will be automagically created when we save the managed expert because of their relationship
    }
    
    func saveChanges() {
        let newExpert = ExpertProfile(id: expert.id,
                                      image: "SampleProfile1",
                                      name: name,
                                      description: description,
                                      documents: expert.documents)
        
        let _ = CDExpert.managedExpert(from: newExpert, context: moc)
        do {
            try moc.save()
        } catch {
            print("Error saving to Core data")
        }
    }
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: PreviewSamples.expert)
    }
}

