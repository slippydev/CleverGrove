//
//  ExpertImporter.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-30.
//

import Foundation
import UniformTypeIdentifiers

enum FileError: Error {
    case exportError
    case importError
}

struct ExpertImporter {
    private let fileReader = FileReader()
    
    func read(url: URL) throws -> ExpertJSON {
        guard let (data, type) = fileReader.openFile(at: url) as? (Data, UTType) else {
            throw FileError.importError
        }
        guard type.conforms(to: .expertFileFormat) else { throw FileError.importError }
        
        return try decodeFromJSON(data: data)
    }
    
    func decodeFromJSON(data: Data) throws -> ExpertJSON {
        let decoder = JSONDecoder()
        let expertJSON = try decoder.decode(ExpertJSON.self, from: data)
        return expertJSON
    }
}
