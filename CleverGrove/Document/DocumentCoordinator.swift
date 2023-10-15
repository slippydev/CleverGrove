//
//  DocumentCoordinator.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-22.
//

import Foundation
import UniformTypeIdentifiers

@MainActor
final class DocumentCoordinator: ObservableObject {
    static let shared = DocumentCoordinator()
    private let parser = Parser()
    private let dataController = DataController.shared
    @Published var jobs = [UUID: Double]()
    
    private init() {
    }
    
    func newDocument(at url: URL,
                     dataType: UTType) -> CDDocument {
        let document = CDDocument.document(context: dataController.managedObjectContext,
                                           fileURL: url,
                                           fileType: FileType.fileType(for: dataType) ?? .text,
                                           status: .untrained)
        return document
    }
    
    func addDocument(at url: URL,
                     with data: Data,
                     to expert: CDExpert,
                     dataType: UTType) async throws
    {
        let document = newDocument(at: url, dataType: dataType)
        try await addDocument(document, to: expert, data: data, dataType: dataType)
    }
    
    func addDocument(_ document: CDDocument, to expert: CDExpert, data: Data, dataType: UTType) async throws {
        expert.addToDocuments(document)
        document.status = DocumentStatus.training.rawValue
        DataController.shared.save()
        
        do {
            try await parseDocument(document, data: data, dataType: dataType)
            try await parser.getExpertise(for: expert, from: document)
            DataController.shared.save()
            document.status = DocumentStatus.trained.rawValue
        } catch {
            CGLogger().logError(error)
            expert.removeFromDocuments(document)
            dataController.save()
            throw error
        }
    }
    
    private func parseDocument(_ document: CDDocument, data: Data, dataType: UTType) async throws {
        let jobID = document.id!
        let progressHandler: (Double) -> Void = { progress in
            DispatchQueue.main.async {
                self.jobs[jobID] = progress
            }
        }
        
        let result = try await parser.parse(document: document, data: data, dataType: dataType, progressHandler: progressHandler)
        dataController.store(embeddings: result.embeddings, textChunks: result.textChunks, in: document)
    }
    
}
