//
//  FilePicker.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//

import SwiftUI
import UniformTypeIdentifiers
import Zip

/**
 A SwiftUI wrapper for UIDocumentPickerViewController.
 */
struct FilePicker: UIViewControllerRepresentable {
    
    @Binding var fileData: Data?
    @Binding var fileURL: URL?
    @Binding var documentType: UTType?
    
    private let fileReader = FileReader()
    private let contentTypes:[UTType] = [.folder, .text, .pdf, .docx]
    
    /**
     Initializes the FilePicker.
     
     - Parameters:
     - fileData: A binding to the Data representing the selected file's content.
     - fileURL: A binding to the URL of the selected file.
     - documentType: A binding to the UTType representing the type of the selected document.
     */
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
        
    /**
     Creates the UIDocumentPickerViewController.
     
     - Parameter context: The context provided by SwiftUI.
     
     - Returns: The configured UIDocumentPickerViewController.
     */
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    /**
     Updates the UIDocumentPickerViewController.
     
     - Parameters:
     - uiViewController: The UIDocumentPickerViewController to update.
     - context: The context provided by SwiftUI.
     */
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    /**
     Creates a Coordinator for handling document picker events.
     
     - Returns: The created Coordinator.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}


