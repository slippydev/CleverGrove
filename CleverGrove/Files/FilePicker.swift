//
//  FilePicker.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//

import SwiftUI
import UniformTypeIdentifiers
import Zip


struct FilePicker: UIViewControllerRepresentable {
    
    @Binding var fileData: Data?
    @Binding var fileURL: URL?
    @Binding var documentType: UTType?
    
    private let fileReader = FileReader()
    private let contentTypes:[UTType] = [.folder, .text, .pdf, .docx]
    
    init(fileData: Binding<Data?>, fileURL: Binding<URL?>, documentType: Binding<UTType?>) {
        _fileData = fileData
        _fileURL = fileURL
        _documentType = documentType
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker
        
        init(_ parent: FilePicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            let (data, type) = parent.fileReader.openFile(at: url)
            if let data = data, let type = type {
                self.parent.fileURL = url
                self.parent.fileData = data
                self.parent.documentType = type
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


