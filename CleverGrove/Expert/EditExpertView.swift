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
    @State private var expertFileURL: URL?
    
    // Document Properties
    @State private var fileData: Data?
    @State private var fileURL: URL?
    @State private var documentType: UTType?
    
    // Flags for showing sheets and alerts
    @State private var isShowingFilePicker = false
    @State private var isShowingImagePicker = false
    @State private var isShowingShareSheet = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    // Focus States
    @FocusState private var nameInFocus: Bool
    @FocusState private var descriptionInFocus: Bool
    
    var body: some View {
            VStack {
                HStack {
                    Button() {
                        expertFileURL = exportExpert()
                        isShowingShareSheet = (expertFileURL != nil)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .frame(width: 20, height: 25, alignment: .bottomTrailing)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Button() {
                        saveChanges()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                VStack(alignment: .center) {
                    HStack(alignment: .top) {
                        CharacterImage(image: expert.image ?? "Person", isSelected: .constant(false))
                            .overlay(alignment: .bottomTrailing) {
                                Image(systemName: "square.and.pencil")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .bottomTrailing)
                                    .foregroundColor(.blue)
                                    .offset(CGSize(width: 15, height: 5))
                            }
                            .onTapGesture {
                                isShowingImagePicker = true
                            }
                            .padding(.trailing, 20)
                            .offset(CGSize(width: 0, height: 20))
                        VStack {
                            HStack {
                                Text("Name")
                                    .font(.headline)
                                Spacer()
                            }
                            .offset(CGSize(width: 0, height: 10))
                            TextField(expert.name ?? "", text: $name)
                                .focused($nameInFocus)
                                .font(.headline.bold())
                                .padding(5)
                                .background(Color("TextFieldBG"))
                                .cornerRadius(4)
                                .shadow(radius: 1.0)
                            HStack {
                                Text("Personality")
                                    .font(.headline)
                                Spacer()
                            }
                            .offset(CGSize(width: 0, height: 10))
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
                    HStack {
                        Text(expertise)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 10)
                        Spacer()
                    }
//                    TextEditor(text: $expertise)
//                        .focused($descriptionInFocus)
//                        .scrollContentBackground(.hidden)
//                        .background(Color("TextFieldBG"))
//                        .frame(minHeight: 50, maxHeight: 50)
//                        .cornerRadius(4)
//                        .shadow(radius: 1.0)
                }
//                .frame(minHeight: 250)
                .padding()
//                .offset(CGSize(width: 0, height: -10))
                VStack {
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
//                .offset(CGSize(width: 0, height: -50))
            }
            
            .sheet(isPresented: $isShowingFilePicker) {
                FilePicker(fileData: $fileData, fileURL: $fileURL, documentType: $documentType)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                CharacterPicker(selectedImage: $selectedProfileImage)
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = expertFileURL {
                    ShareSheet(activityItems: [url], completion: shareCompletion)
                }
            }
            .alert( Text("Error"), isPresented: $isShowingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: fileData) { newValue in
                if let data = fileData, let url = fileURL, let dataType = documentType {
                    addDocument(data: data, url: url, dataType: dataType)
                }
            }
            .onChange(of: selectedProfileImage, perform: { _ in
                expert.image = selectedProfileImage
            })
            .onChange(of: expertFileURL, perform: { _ in }) // weird quantum shit happening here. Need to observe it for expertFileURL to work properly
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
    
    func addDocument(data: Data, url: URL, dataType: UTType) {
        Task {
            defer { fileData = nil } // reset
            do {
                try await DocumentCoordinator.shared.addDocument(at: url, with: data, to: expert, dataType: dataType)
                expertise = expert.expertise ?? ""
            } catch let error as URLError {
                print(error.userInfo)
                showError("\(error.localizedDescription).\nThere may be a problem with the server. Please try again later.")
            } catch {
                showError("Error parsing document: \(error.localizedDescription)")
            }
        }
    }
    
    func saveChanges() {
        expert.name = name
        expert.personality = communicationStyle.rawValue
        if !selectedProfileImage.isEmpty {
            expert.image = selectedProfileImage
        }
        expert.lastUpdated = Date.now
        DataController.shared.save()
    }
    
    func exportExpert() -> URL? {
        do {
            let exporter = ExpertExporter(expert: expert)
            let url = try exporter.export(to: expert.fileName)
            return url
        } catch {
            showError("Error exporting expert: \(error.localizedDescription)")
            return nil
        }
    }
    
    func shareCompletion(_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) {
        // delete the expert file from local storage
        do {
            if let url = expertFileURL {
                try FileManager.default.removeItem(at: url)
            }
            // auto-dismiss the view if the operation was successful, but not if they canceled
            if completed {
                dismiss()
            }
        } catch {
            AILogger().logError(error)
            print("Removing local expert file after sharing failed.")
        }
    }
    
    func showError(_ text: String) {
        errorMessage = text
        isShowingError = true
    }
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: PreviewSamples.expert)
    }
}

