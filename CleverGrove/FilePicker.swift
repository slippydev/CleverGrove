//
//  FilePicker.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//

import SwiftUI
import UniformTypeIdentifiers
import Zip


extension UTType {
    // Because Apple just want to be jerks.
    static let docx = UTType(filenameExtension: "docx")!
}

struct FilePicker: UIViewControllerRepresentable {
    
    @Binding var fileData: Data?
    @Binding var fileURL: URL?
    @Binding var documentType: UTType?
    
    private let contentTypes:[UTType] = [.folder, .text, .pdf, .docx]
    private let docxSubpath = "word/document.xml"
    
    init(fileData: Binding<Data?>, fileURL: Binding<URL?>, documentType: Binding<UTType?>) {
        _fileData = fileData
        _fileURL = fileURL
        _documentType = documentType
        
        Zip.addCustomFileExtension("docx") // so we can unzip docx files
    }
    
    func readData(from url: URL) -> Data? {
        guard let fileType = UTType(filenameExtension: url.pathExtension) else { return nil }
        if fileType.conforms(to: .docx) {
            guard let url = unzip(url: url, subpath: docxSubpath) else { return nil }
            return try? Data(contentsOf: url)
        } else {
            return try? Data(contentsOf: url)
        }
    }
    
    func unzip(url: URL, subpath: String?) -> URL? {
        do {
            var path = try Zip.quickUnzipFile(url)
            if let subpath = subpath {
                path.append(component: subpath)
            }
            return path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
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
                guard let data = parent.readData(from: url), let type = UTType(filenameExtension: url.pathExtension) else { return }
                self.parent.fileURL = url
                self.parent.fileData = data
                self.parent.documentType = type
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


