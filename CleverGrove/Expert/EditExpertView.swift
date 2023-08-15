//
//  EditExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI
import UniformTypeIdentifiers

class ExpertToEdit: ObservableObject {
    @Published var expert: CDExpert?
}

struct EditExpertView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var expert: CDExpert
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var image: Image = Image(systemName: "questionmark.square.dashed")
    @State private var fileData: Data?
    @State private var fileURL: URL?
    @State private var documentType: UTType?
    @State private var documents = [CDDocument]()
    
    @State private var isShowingFilePicker = false
    @State private var isShowingParsingError = false
   
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center) {
                        ZStack {
                            ExpertProfileImage(image: Image(expert.image ?? ""), geo: geometry)
                                .colorMultiply(.gray)
                                .saturation(0.5)
                            SelectionBox(geo: geometry)
                        }
                        Divider()
                        TextField(expert.name ?? "", text: $name)
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
                    DocumentList(expert: expert)
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
            .sheet(isPresented: $isShowingFilePicker) {
                FilePicker(fileData: $fileData, fileURL: $fileURL, documentType: $documentType)
            }
            .alert("Parsing failure with this document.", isPresented: $isShowingParsingError) {
                Button("OK", role: .cancel) { }
            }
            .onChange(of: fileData) { newValue in
                if let data = fileData, let url = fileURL, let dataType = documentType {
                    addDocument(data: data, url: url, dataType: dataType)
                }
            }
            .onAppear() {
                description = expert.desc ?? ""
                name = expert.name ?? ""
            }
        }
    }
    
    func addDocument(data: Data, url: URL, dataType: UTType) {
        let document = CDDocument.document(context: DataController.shared.managedObjectContext,
                                           fileURL: url,
                                           fileType: FileType.fileType(for: dataType) ?? .text,
                                           status: .training)
        expert.addToDocuments(document)
        DataController.shared.save()
        
        let parser = DocumentParser(data: data,
                                    dataType: dataType,
                                    document: document,
                                    expert: expert)
        Task {
            do {
                try await parser.parse()
                document.status = DocumentStatus.trained.rawValue
                DataController.shared.save()
            } catch {
                // Parsing failed
                document.status = DocumentStatus.untrained.rawValue
                DataController.shared.save()
            }
        }
    }
    
    func saveChanges() {
        expert.name = name
        expert.desc = description
        expert.image = "SampleProfile1"
        DataController.shared.save()
    }
    
}

//struct EditExpertView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditExpertView(expert: PreviewSamples.expert)
//    }
//}

