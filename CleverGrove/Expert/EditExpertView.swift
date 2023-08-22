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
    @State private var fileData: Data?
    @State private var fileURL: URL?
    @State private var documentType: UTType?
    @State private var documents = [CDDocument]()
    @State private var trainingProgress = 0.0
    @State private var selectedProfileImage: String = ""
    
    @State private var isShowingFilePicker = false
    @State private var isShowingParsingError = false
    @State private var isShowingImagePicker = false
    @State private var parsingTask: Task<Void, Never>? = nil
    
    @FocusState private var nameInFocus: Bool
    @FocusState private var descriptionInFocus: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center) {
                    ZStack {
                        CharacterImage(image: expert.image ?? "Person", isSelected: .constant(false))
                            .frame(minHeight: 120)
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .bottomTrailing)
                                    .foregroundColor(.blue)
                                    .offset(CGSize(width: 15, height: -10))
                            }
                            .onTapGesture {
                                isShowingImagePicker = true
                            }
                    }
                    
                    TextField(expert.name ?? "", text: $name)
                        .focused($nameInFocus)
                        .font(.title.bold())
                        .padding(5)
                        .multilineTextAlignment(.center)
                        .background(Color("TextFieldBG"))
                        .cornerRadius(10)
                        .shadow(radius: 1.0)
                    
                    Text("\(name) is an expert at:")
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .padding(.top, 10)
                        
                    TextEditor(text: $description)
                        .focused($descriptionInFocus)
                        .multilineTextAlignment(.center)
                        .scrollContentBackground(.hidden)
                        .background(Color("TextFieldBG"))
                        .frame(minHeight: 75, maxHeight: 75)
                        .cornerRadius(10)
                        .shadow(radius: 1.0)
                }
                .frame(minHeight: 250)
                .padding()
                
                Divider()
                HStack {
                    Text("Training Documents")
                        .font(.title2)
                        .padding([.top, .leading], 10)
                    Spacer()
                    Button() {
                        nameInFocus = false
                        descriptionInFocus = false
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
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(role: .cancel) {
                        DataController.shared.undoChanges()
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button() {
                        saveChanges()
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }
            .sheet(isPresented: $isShowingFilePicker) {
                FilePicker(fileData: $fileData, fileURL: $fileURL, documentType: $documentType)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                CharacterPicker(selectedImage: $selectedProfileImage)
            }
            .alert("Parsing failure with this document.", isPresented: $isShowingParsingError) {
                Button("OK", role: .cancel) { }
            }
            .onChange(of: fileData) { newValue in
                if let data = fileData, let url = fileURL, let dataType = documentType {
                    addDocument(data: data, url: url, dataType: dataType)
                }
            }
            .onChange(of: selectedProfileImage, perform: { _ in
                expert.image = selectedProfileImage
            })
            .onAppear() {
                if (expert.image ?? "").isEmpty {
                    nameInFocus = true
                }
                description = expert.desc ?? ""
                name = expert.name ?? ""
            }
            .onDisappear {
                // Cancel the parsing task if the view is disappearing
                DataController.shared.undoChanges()
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
                defer { parsingTask = nil }
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
        if !selectedProfileImage.isEmpty {
            expert.image = selectedProfileImage
        }
        DataController.shared.save()
    }
    
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: PreviewSamples.expert)
    }
}

