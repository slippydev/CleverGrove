//
//  DocumentDecoder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-13.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers



protocol DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String]
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
