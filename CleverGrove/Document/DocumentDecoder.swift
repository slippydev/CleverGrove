//
//  DocumentDecoder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-13.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers

extension String {
    func splitIntoChunks(ofSize chunkSize: Int) -> [String] {
        var startIndex = self.startIndex
        var chunks: [String] = []
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: chunkSize, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = self[startIndex..<endIndex]
            chunks.append(String(chunk))
            startIndex = endIndex
        }
        
        return chunks
    }
}

protocol DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String]
}

struct DocumentDecode {
    static func decode(data: Data, type: UTType, chunkSize: Int) throws -> [String] {
        guard let decoder = decoder(for: type) else { return [] }
        return try decoder.decode(from: data, chunkSize: chunkSize)
    }
    
    static func decoder(for type: UTType) -> DocumentDecoder? {
        if type.conforms(to: .text) {
            return TextDecoder()
        } else if type.conforms(to: .pdf) {
            return PDFDecoder()
        } else if type.conforms(to: .docx) {
            return DocxDecoder()
        } else {
            return nil
        }
    }
}

struct TextDecoder: DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String] {
        let text = String(decoding: data, as: UTF8.self)
        let chunks = text.splitIntoChunks(ofSize: chunkSize)
        return chunks
    }
}

struct PDFDecoder: DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String] {
        guard let pdf = PDFDocument(data: data) else { throw ParserError.fileTypeError }
        guard let text = pdf.string else { throw ParserError.fileTypeError }
        let chunks = text.splitIntoChunks(ofSize: chunkSize)
        return chunks
    }
}
