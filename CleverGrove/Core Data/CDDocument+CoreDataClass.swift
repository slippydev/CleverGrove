//
//  CDDocument+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-10.
//
//

import Foundation
import CoreData

@objc(CDDocument)
public class CDDocument: NSManagedObject {
    static func managedDocument(from document: DocumentInfo, context: NSManagedObjectContext) -> CDDocument {
        let managedDoc = CDDocument(context: context)
        managedDoc.id = document.id
        managedDoc.fileName = document.fileName
        managedDoc.filetype = document.fileType.rawValue
        managedDoc.path = document.path
        managedDoc.status = document.status.rawValue
        return managedDoc
    }
    
    func document() -> DocumentInfo {
        return DocumentInfo(id: id ?? UUID(),
                            fileType: FileType(rawValue: filetype ?? "text") ?? .text,
                            fileName: fileName ?? "",
                            path: path ?? "",
                            status: DocumentStatus(rawValue: status ?? "") ?? .untrained)
    }
    
}
