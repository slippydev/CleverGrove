//
//  FileReader.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-23.
//

import Foundation
import UniformTypeIdentifiers
import Zip


extension UTType {
    // Because Apple just want to be jerks.
    static let docx = UTType(filenameExtension: "docx")!
}

class FileReader {
    private let docxSubpath = "word/document.xml"
    private var urlToCleanup: URL?
    
    init() {
        Zip.addCustomFileExtension("docx") // so we can unzip docx files
        Zip.addCustomFileExtension("expert") // sw we can zip and unzip our .expert files
    }
    
    func openFile(at url: URL) -> (Data?, UTType?) {
        // Start accessing a security-scoped resource.
        // Sometimes this is necessary and sometimes it isn't.
        // Opening files from icloud storage seems to need it, but opening files
        // shared from messages doesn't seem to need it, so the call fails, but
        // accessing the data works fine. So we call this but don't care about
        // the outcome.
        let _ = url.startAccessingSecurityScopedResource()
        
        // Make sure you release the security-scoped resource when you finish.
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let type = UTType(filenameExtension: url.pathExtension) else { return (nil, nil) }
        var error: NSError? = nil
        var data: Data?
        
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { url in
            data = readData(from: url, fileType: type)
            if let urlToCleanup = urlToCleanup {
                do {
                    try FileManager.default.removeItem(at: urlToCleanup)
                } catch {
                    AILogger().logError(error)
                }
            }
        }
        if let error = error {
            print("Error \(error.localizedDescription)")
        }
        return (data, type)
    }
    
    private func readData(from url: URL, fileType: UTType) -> Data? {
        if fileType.conforms(to: .expertFileFormat) {
            guard let url = unzip(url: url, subpath: ExpertExporter.expertJSONSubpath) else { return nil }
            return try? Data(contentsOf: url)
        } else if fileType.conforms(to: .docx) {
            guard let url = unzip(url: url, subpath: docxSubpath) else { return nil }
            return try? Data(contentsOf: url)
        } else {
            return try? Data(contentsOf: url)
        }
    }
    
    private func unzip(url: URL, subpath: String? = nil) -> URL? {
        do {
            var path = try Zip.quickUnzipFile(url)
            urlToCleanup = path
            if let subpath = subpath {
                path.append(component: subpath)
            }
            return path
        } catch {
            print(error.localizedDescription)
            AILogger().logError(error)
            return nil
        }
    }
}
