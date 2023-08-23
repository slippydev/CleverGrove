//
//  FileImportView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-22.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileImportView: View {
    class SelectedExpert: ObservableObject {
        @Published var expert: CDExpert?
    }
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var experts: FetchedResults<CDExpert>
    
    @Environment(\.dismiss) var dismiss
    
    let url: URL?
    private let fileReader = FileReader()
    @StateObject var selectedExpert = SelectedExpert()
    @State private var fileData: Data?
    @State private var fileType: UTType?
    @State private var isTraining = false
    @State private var isShowingError = false
    @State private var errorMessage = ""
    
    func shouldHide(_ expert: CDExpert) -> Bool {
        isTraining && expert != selectedExpert.expert
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", role: .cancel) { dismiss() }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            if let url = url {
                Text("Choose an expert to train on \(url.lastPathComponent)?")
                    .font(.headline)
                    .padding(.horizontal, 35)
            }
            List {
                ForEach(experts, id: \.self) { expert in
                    ExpertSummary(expert: expert)
                        .onTapGesture {
                            if isTraining == false {
                                selectedExpert.expert = expert
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isTraining = true
                                }
                                Task { await trainExpert() }
                            }
                        }
                        .opacity(shouldHide(expert) ? 0.1 : 1.0)
                    if expert == selectedExpert.expert, let url = url, let document = selectedExpertHasDocument(named: url.lastPathComponent) {
                        DocumentCapsule(document: document)
                    }
                }
            }
            .scrollIndicators(.hidden)
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
        let document: CDDocument? = selectedExpert.expert?.documents?.first(where: { document in
            (document as? CDDocument)?.fileName == name
        }) as? CDDocument
        return document
    }
    
    func openFile() async {
        guard let url = url else {
            errorMessage = "Error reading the file URL"
            isShowingError = true
            return
        }
        let (data, type) = fileReader.openFile(at: url)
        fileData = data
        fileType = type
    }
    
    func trainExpert() async {
        Task {
            do {
                guard let url = url, let data = fileData, let type = fileType, let expert = selectedExpert.expert else { return }
                try await DocumentCoordinator.shared.addDocument(at: url, with: data, to: expert, dataType: type)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isShowingError = true
            }
        }
    }

}

struct FileImportView_Previews: PreviewProvider {
    static var previews: some View {
        FileImportView(url: URL(string: "http://text.com/myfile.pdf"))
    }
}
