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
    
    // Expert Properties
    @ObservedObject var expert: CDExpert
    @State private var name: String = ""
    @State private var expertise: String = ""
    @State private var communicationStyle = CommunicationStyle.formal
    @State private var selectedProfileImage: String = ""
    
    // Document Properties
    @State private var fileData: Data?
    @State private var fileURL: URL?
    @State private var documentType: UTType?
    
    // Flags for showing sheets and alerts
    @State private var isShowingFilePicker = false
    @State private var isShowingParsingError = false
    @State private var isShowingImagePicker = false
    
    // Focus States
    @FocusState private var nameInFocus: Bool
    @FocusState private var descriptionInFocus: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center) {
                    HStack(alignment: .bottom) {
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
                            .padding(.trailing, 20)
                        VStack {
                            HStack {
                                Text("Name")
                                    .frame(alignment: .bottomLeading)
                                Spacer()
                            }
                            TextField(expert.name ?? "", text: $name)
                                .focused($nameInFocus)
                                .font(.headline.bold())
                                .padding(5)
                                .background(Color("TextFieldBG"))
                                .cornerRadius(4)
                                .shadow(radius: 1.0)
                            HStack {
                                Text("Personality")
                                Spacer()
                            }
                            HStack {
                                Picker("Communication Style", selection: $communicationStyle) {
                                    ForEach(CommunicationStyle.allCases, id:\.self) { option in
                                        Text(option.rawValue)
                                    }
                                }
                                .background(Color("TextFieldBG"))
                                .tint(.primary)
                                .cornerRadius(4)
                                .shadow(radius: 1.0)
                                Spacer()
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    HStack {
                        Text("\(name) is an expert at:")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 5)
                        Spacer()
                    }
                    Text(expertise)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
//                    TextEditor(text: $expertise)
//                        .focused($descriptionInFocus)
//                        .scrollContentBackground(.hidden)
//                        .background(Color("TextFieldBG"))
//                        .frame(minHeight: 50, maxHeight: 50)
//                        .cornerRadius(4)
//                        .shadow(radius: 1.0)
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
                }
                DocumentList(expert: expert)
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
//                    .opacity(hasChanges ? 1.0 : 0.0)
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
                expertise = expert.expertise ?? ""
                name = expert.name ?? ""
                communicationStyle = CommunicationStyle(rawValue: expert.personality ?? "") ?? .formal
            }
            .onDisappear {
                DataController.shared.undoChanges()
            }
        }
    }
    
    func addDocument(data: Data, url: URL, dataType: UTType) {
        Task {
            do {
                try await DocumentCoordinator.shared.addDocument(at: url, with: data, to: expert, dataType: dataType)
                fileData = nil // reset
            } catch {
                isShowingParsingError = true
            }
        }
    }
    
    func saveChanges() {
        expert.name = name
//        expert.desc = description
        expert.personality = communicationStyle.rawValue
        if !selectedProfileImage.isEmpty {
            expert.image = selectedProfileImage
        }
        expert.lastUpdated = Date.now
        DataController.shared.save()
    }
    
    
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: PreviewSamples.expert)
    }
}

