//
//  FileImportView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-22.
//

import SwiftUI
import UniformTypeIdentifiers

class Document: ObservableObject {
    @Published var document: CDDocument?
}

struct FileImportView: View {
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var experts: FetchedResults<CDExpert>
    
    @Environment(\.dismiss) var dismiss
    
    let url: URL?
    private let fileReader = FileReader()
    @ObservedObject var expertToTrain : Expert
    @StateObject var documentToTrain = Document()
    @State private var fileData: Data?
    @State private var fileType: UTType?
    @State private var isTraining = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    func shouldHide(_ expert: CDExpert) -> Bool {
        isTraining && expert != expertToTrain.expert
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            if let document = documentToTrain.document {
                DocumentCapsule(document: document)
                    .padding(.vertical, 30)
            }
            
            Button {
                Task { await startTraining() }
            } label: {
                Text("Train a new expert")
                    .foregroundColor(.blue)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 20)
            .frame(width: 350, height: 70)
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                )
            .opacity(isTraining ? 0 : 1.0)
            
            Text("Or add document to an existing expert:")
                .font(.headline)
                .opacity(isTraining ? 0 : 1.0)
                .padding()
            
            List {
                ForEach(experts, id: \.self) { expert in
                    ExpertSummary(expert: expert)
                        .onTapGesture {
                            Task { await startTraining(expert) }
                        }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .opacity(isTraining ? 0 : 1.0)
        }
        .task {
            await openFile()
        }
        .alert( Text("Error"), isPresented: $isShowingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func selectedExpertHasDocument(named name: String) -> CDDocument? {
        let document: CDDocument? = expertToTrain.expert?.documents?.first(where: { document in
            (document as? CDDocument)?.fileName == name
        }) as? CDDocument
        return document
    }
    
    func openFile() async {
        guard let url = url else {
            showError("Error reading the file URL")
            return
        }
        guard let (data, type) = fileReader.openFile(at: url) as? (Data, UTType) else {
            showError("Could not read file contents")
            return
        }
        fileData = data
        fileType = type
        documentToTrain.document = DocumentCoordinator.shared.newDocument(at: url, dataType: type)
    }
    
    func startTraining(_ expert: CDExpert? = nil) async {
        if isTraining == false {
            if let expert = expert {
                expertToTrain.expert = expert
            } else {
                // Create a new expert to edit
                expertToTrain.expert = CDExpert.expert(context: DataController.shared.managedObjectContext,
                                                      name: CDExpert.randomName(),
                                                      description: "...details about the area of expertise.")
            }
            withAnimation(.easeOut(duration: 0.5)) {
                isTraining = true
            }
            Task { await trainExpert() }
        }
    }
    
    func trainExpert() async {
        Task {
            do {
                guard let document = documentToTrain.document, let data = fileData, let type = fileType, let expert = expertToTrain.expert else { return }
                document.status = DocumentStatus.training.rawValue
                try await DocumentCoordinator.shared.addDocument(document, to: expert, data: data, dataType: type)
                dismiss()
            } catch {
                showError(error.localizedDescription)
            }
        }
    }
    
    func showError(_ text: String) {
        errorMessage = text
        isShowingError = true
    }

}

struct FileImportView_Previews: PreviewProvider {
    static var previews: some View {
        FileImportView(url: URL(string: "http://text.com/myfile.pdf"), expertToTrain: Expert())
    }
}
