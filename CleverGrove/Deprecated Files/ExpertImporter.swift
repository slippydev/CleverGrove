//
//  ExpertImporter.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-30.
//

import Foundation
import UniformTypeIdentifiers

/**
 An enumeration representing possible file-related errors.
 
 - Cases:
 - exportError: An error occurred during export.
 - importError: An error occurred during import.
 */
enum FileError: Error {
    case exportError
    case importError
}

/**
 A structure responsible for importing an expert from a JSON file.
 
 - Properties:
 - fileReader: A `FileReader` instance to read the JSON file.
 
 - Methods:
 - read(url:): Reads an expert from a JSON file.
 - decodeFromJSON(data:): Decodes an expert from JSON data.
 - installEmbeddedExpert(): Installs an embedded expert from a bundled JSON file.
 */
struct ExpertImporter {
    private let fileReader = FileReader()
    
    /**
     Reads an expert from a JSON file located at the given URL.
     
     - Parameters:
     - url: The URL of the JSON file to read.
     
     - Throws: An error if there is an issue with reading the JSON file.
     
     - Returns: An `ExpertJSON` object representing the imported expert.
     */
    func read(url: URL) throws -> ExpertJSON {
        guard let (data, type) = fileReader.openFile(at: url) as? (Data, UTType) else {
            throw FileError.importError
        }
        guard type.conforms(to: .expertFileFormat) else { throw FileError.importError }
        
        return try decodeFromJSON(data: data)
    }
    
    /**
     Decodes an expert from JSON data.
     
     - Parameters:
     - data: The JSON data to decode.
     
     - Throws: An error if there is an issue with decoding.
     
     - Returns: An `ExpertJSON` object representing the decoded expert.
     */
    private func decodeFromJSON(data: Data) throws -> ExpertJSON {
        let decoder = JSONDecoder()
        let expertJSON = try decoder.decode(ExpertJSON.self, from: data)
        return expertJSON
    }
    
    /**
     Installs an embedded expert from a bundled JSON file.
     
     - Throws: An error if there is an issue with installing the expert.
     */
    func installEmbeddedExpert() throws {
        guard let url = Bundle.main.url(forResource: "Clever Cat", withExtension: "expert") else { return }
        let json = try read(url: url)
        let _ = CDExpert.expert(from: json, context: DataController.shared.managedObjectContext)
        DataController.shared.save()
    }
}
