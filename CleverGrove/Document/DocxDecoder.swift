//
//  DocxDecoder.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-21.
//

import Foundation
import UniformTypeIdentifiers
import XMLCoder

/*
 DOCX XML Format
 <w:body>
    <w:p> Paragraph
        <w:r> Text Run
            <w:t>Text</w:t> Text
        </w:r>
    </w:p>
 </w:body>
 */

struct DocX: Codable {
    let body: DocXBody

    enum CodingKeys: String, CodingKey {
        case body = "w:body"
    }
}

struct DocXBody: Codable {
    let paragraphs: [DocXParagraph]

    enum CodingKeys: String, CodingKey {
        case paragraphs = "w:p"
    }
}

struct DocXParagraph: Codable {
    let textRuns: [DocXTextRun]

    enum CodingKeys: String, CodingKey {
        case textRuns = "w:r"
    }
}

struct DocXTextRun: Codable {
    let text: String?

    enum CodingKeys: String, CodingKey {
        case text = "w:t"
    }
}

struct DocxDecoder: DocumentDecoder {
    func decode(from data: Data, chunkSize: Int) throws -> [String] {
        print(String(data: data, encoding: .utf8) ?? "")
        let text = try parseXML(data: data)
        let chunks = text.splitIntoChunks(ofSize: chunkSize)
        return chunks
    }
    
    private func parseXML(data: Data) throws -> String {
        let decoder = XMLDecoder()
        let document = try decoder.decode(DocX.self, from: data)
        
        var bodyText = ""
        for paragraph in document.body.paragraphs {
            bodyText.append("\n")
            for textRun in paragraph.textRuns {
                if let text = textRun.text {
                    bodyText.append(contentsOf: text)
                }
            }
            bodyText.append("\n")
        }
        return bodyText
    }
    
}
