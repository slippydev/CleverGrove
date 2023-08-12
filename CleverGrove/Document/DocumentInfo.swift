//
//  DocumentInfo.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentInfo: Identifiable {
    let id: UUID
    let fileType: FileType
    let fileName: String
    let path: String
    var status: DocumentStatus
    
    init(id: UUID = UUID(), fileType: FileType, fileName: String, path: String, status: DocumentStatus) {
        self.id = id
        self.fileType = fileType
        self.fileName = fileName
        self.path = path
        self.status = status
    }
    
    init(fileURL: URL, fileType: FileType, status: DocumentStatus) {
        self.path = fileURL.absoluteString
        self.fileName = fileURL.lastPathComponent
        self.id = UUID()
        self.fileType = fileType
        self.status = status
    }
    
    var image: Image {
        fileType.image
    }
    
    mutating func changeStatus(newStatus: DocumentStatus) {
        self.status = newStatus
    }
}

enum FileType: String {
    case text = "text"
    // case pdf = "pdf"
    // href link = "link"
    // ...etc
    
    var image: Image {
        var image: Image
        switch self {
        case .text:
            image = Image(systemName: "doc.plaintext")
        }
        return image
    }
}

enum DocumentStatus: String {
    case untrained = "Untrained"
    case training = "Training"
    case trained = "Trained"
}
