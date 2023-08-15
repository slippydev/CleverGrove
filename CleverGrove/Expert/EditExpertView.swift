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
    @State private var trainingProgress = 0.0

    @State private var isShowingFilePicker = false
    @State private var isShowingParsingError = false
    @State private var parsingTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
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
                        .disabled(parsingTask != nil) // only show the button to add documents if we're not already parsing one.
                    }
                    DocumentList(expert: expert, trainingProgress: $trainingProgress)
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
            .onDisappear {
                // Cancel the parsing task if the view is disappearing
                parsingTask?.cancel()
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
        let progressHandler: (Double) -> Void = { progress in
            DispatchQueue.main.async {
                self.trainingProgress = progress
            }
        }
        
        parsingTask = Task {
            do {
                try await parser.parse(progressHandler: progressHandler)
                document.status = DocumentStatus.trained.rawValue
                DataController.shared.save()
            } catch {
                // Parsing failed
                expert.removeFromDocuments(document)
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

