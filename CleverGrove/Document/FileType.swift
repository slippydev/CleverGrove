//
//  FileType.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI
import UniformTypeIdentifiers

enum DocumentStatus: String {
    case untrained = "Untrained"
    case training = "Training"
    case trained = "Trained"
}

enum FileType: String {
    case text = "text"
    case pdf = "pdf"
    case docx = "docx"
    // href link = "link"
    // ...etc
    
    var image: Image {
        var image: Image
        switch self {
        case .text:
            image = Image(systemName: "doc.plaintext")
        case .pdf:
            image = Image(systemName: "doc.richtext")
        case .docx:
            image = Image(systemName: "doc")
        }
        return image
    }
    
    static func fileType(for type: UTType) -> FileType? {
        switch type {
        case .text:
            return .text
        case .pdf:
            return .pdf
        case UTType(filenameExtension: "docx"):
            return .docx
        default:
            return nil
        }
    }
}


