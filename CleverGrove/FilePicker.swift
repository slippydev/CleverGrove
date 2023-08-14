//
//  FilePicker.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePicker: UIViewControllerRepresentable {
    
    @Binding var fileData: Data?
    @Binding var fileURL: URL?
    @Binding var documentType: UTType?
    
    private let contentTypes:[UTType] = [.folder, .text, .pdf]
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker
        
        init(_ parent: FilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else { return }

            // Make sure you release the security-scoped resource when you finish.
            defer { url.stopAccessingSecurityScopedResource() }
            
            var error: NSError? = nil
            NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { url in
                guard let data = try? Data(contentsOf: url) else { return }
                self.parent.fileURL = url
                self.parent.fileData = data
                self.parent.documentType = UTType(filenameExtension: url.pathExtension)
            }
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
        
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}


