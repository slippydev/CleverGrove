//
//  CDDocument+CoreDataClass.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//
//

import Foundation
import CoreData

@objc(CDDocument)
public class CDDocument: NSManagedObject {

    static func document(from managedDocument: CDDocument) -> DocumentInfo {
        return DocumentInfo(id: managedDocument.id ?? UUID(),
                            fileType: FileType(rawValue: managedDocument.filetype ?? "text") ?? .text,
                            fileName: managedDocument.fileName ?? "",
                            path: managedDocument.path ?? "",
                            status: DocumentStatus(rawValue: managedDocument.status ?? "") ?? .untrained)
    }
    
}
