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
    
    func addDocument(at url: URL,
                     with data: Data,
                     to expert: CDExpert,
                     dataType: UTType) async throws
    {
        let document = CDDocument.document(context: dataController.managedObjectContext,
                                           fileURL: url,
                                           fileType: FileType.fileType(for: dataType) ?? .text,
                                           status: .training)
        expert.addToDocuments(document)
        DataController.shared.save()
        
        let jobID = document.id!
        let progressHandler: (Double) -> Void = { progress in
            DispatchQueue.main.async {
                self.jobs[jobID] = progress
            }
        }
        
        do {
            let result = try await parser.parse(document: document, data: data, dataType: dataType, progressHandler: progressHandler)
            document.status = DocumentStatus.trained.rawValue
            dataController.store(embeddings: result.embeddings, textChunks: result.textChunks, in: document)
        } catch {
            expert.removeFromDocuments(document)
            dataController.save()
            throw error
        }
    }
    
}
