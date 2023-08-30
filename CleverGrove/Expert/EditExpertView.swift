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
    @State private var isShowingParsingError = false
    @State private var isShowingImagePicker = false
    @State private var isShowingShareSheet = false
    
    // Focus States
    @FocusState private var nameInFocus: Bool
    @FocusState private var descriptionInFocus: Bool
    
    var body: some View {
            VStack {
                HStack {
                    Button() {
                        let url = exportExpert()
                        expertFileURL = url
                        isShowingShareSheet = (expertFileURL != nil)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Spacer()
                    Button("Done", role: .cancel) {
                        saveChanges()
                        dismiss()
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
            .onChange(of: expertFileURL, perform: { newValue in
                print("expertFileURL: \(String(describing: newValue))")
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
    
    func addDocument(data: Data, url: URL, dataType: UTType) {
        Task {
            do {
                try await DocumentCoordinator.shared.addDocument(at: url, with: data, to: expert, dataType: dataType)
                fileData = nil // reset
                expertise = expert.expertise ?? ""
            } catch {
                fileData = nil // reset
                isShowingParsingError = true
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
            // FIXME: throw an error
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
            // FIXME: Not much to be done here. Log the error?
            print("Removing local expert file after sharing failed.")
        }
    }
}

struct EditExpertView_Previews: PreviewProvider {
    static var previews: some View {
        EditExpertView(expert: PreviewSamples.expert)
    }
}

