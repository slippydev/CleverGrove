//
//  DocumentDecoder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-13.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers

/**
 An extension of the String type providing a method to split the string into chunks of a specified size.
 */
extension String {
    /**
     Splits the string into chunks of the specified size.
     
     - Parameters:
     - chunkSize: The size of each chunk.
     
     - Returns: An array of string chunks.
     */
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

/**
 A protocol for decoding documents into text chunks.
 */
protocol DocumentDecoder {
    /**
     Decodes a document from data into text chunks of the specified size.
     
     - Parameters:
     - data: The document data.
     - chunkSize: The size of each text chunk.
     
     - Throws: An error if there is an issue during the decoding process.
     
     - Returns: An array of text chunks.
     */
    func decode(from data: Data, chunkSize: Int) throws -> [String]
}

/**
 A struct for decoding documents into text chunks based on the document type.
 */
struct DocumentDecode {
    
    /**
     Decodes a document into text chunks based on its type.
     
     - Parameters:
     - data: The document data.
     - type: The UTType representing the document's data type.
     - chunkSize: The size of each text chunk.
     
     - Throws: An error if there is an issue during the decoding process.
     
     - Returns: An array of text chunks.
     */
    static func decode(data: Data, type: UTType, chunkSize: Int) throws -> [String] {
        guard let decoder = decoder(for: type) else { return [] }
        return try decoder.decode(from: data, chunkSize: chunkSize)
    }
    
    /**
     Returns a document decoder based on the document type.
     
     - Parameters:
     - type: The UTType representing the document's data type.
     
     - Returns: A document decoder for the specified type.
     */
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

/**
 A document decoder for text-based documents.
 */
struct TextDecoder: DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String] {
        let text = String(decoding: data, as: UTF8.self)
        let chunks = text.splitIntoChunks(ofSize: chunkSize)
        return chunks
    }
}

/**
 A document decoder for PDF documents.
 */
struct PDFDecoder: DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String] {
        guard let pdf = PDFDocument(data: data) else { throw ParserError.fileTypeError }
        guard let text = pdf.string else { throw ParserError.fileTypeError }
        let chunks = text.splitIntoChunks(ofSize: chunkSize)
        return chunks
    }
}
