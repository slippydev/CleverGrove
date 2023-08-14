//
//  EditExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI
import UniformTypeIdentifiers

struct EditExpertView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var expert: ExpertProfile
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var image: Image = Image(systemName: "questionmark.square.dashed")
    @State private var fileData: Data?
    @State private var fileURL: URL?
    @State private var documentType: UTType?
    @State private var documents = [DocumentInfo]()
    
    @State private var isShowingFilePicker = false
    @State private var isShowingParsingError = false
    
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
                    DocumentList(documents: $documents)
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
                documents = expert.documents
            }
            .sheet(isPresented: $isShowingFilePicker) {
                FilePicker(fileData: $fileData, fileURL: $fileURL, documentType: $documentType)
            }
            .onChange(of: fileData) { newValue in
                if let data = fileData, let url = fileURL, let dataType = documentType {
                    addDocument(data: data, url: url, dataType: dataType)
                }
            }
        }
    }
    
    func addDocument(data: Data, url: URL, dataType: UTType) {
        let moc = DataController.shared.managedObjectContext
        var document = DocumentInfo(fileURL: url, fileType: .text, status: .training)
        documents.append(document)
        let managedDocument = CDDocument.managedDocument(from: document, context: moc)
        let managedExpert = CDExpert.managedExpert(from: expert, context: moc)
        managedExpert.addToDocuments(managedDocument)
        let parser = DocumentParser(data: data,
                                    dataType: dataType,
                                    document: managedDocument,
                                    expert: managedExpert)
        Task {
            do {
                try await parser.parse()
            } catch {}
        }
        document.changeStatus(newStatus: .trained)
    }
    
    func saveChanges() {
        let newExpert = ExpertProfile(id: expert.id,
                                      image: "SampleProfile1",
                                      name: name,
                                      description: description,
                                      documents: expert.documents)
        let moc = DataController.shared.managedObjectContext
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

