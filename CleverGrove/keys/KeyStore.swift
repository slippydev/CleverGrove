//
//  KeyStore.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

// Gives access to key store PLIST files that store app secrets.
// To add a new secret:
// 1. create a PLIST File
// 2. add keys and values to the PLIST file, using "api_key" and "org_key" (if needed)
// 3. add the file name into the KeyStoreType enum
// 4. add the new file to the .gitignore list
// 5. call KeyStore.key(from:"FILENAME") to get the APIKey instance

import Foundation

enum KeyStoreType: String {
    case openAI = "OpenAI-Info"
}

struct APIKey: Decodable {
    var api_key: String
    var org_key: String
}

struct KeyStore {
    
    static func key(from resource: KeyStoreType) -> APIKey {
        guard let url = Bundle.main.url(forResource: resource.rawValue, withExtension: "plist") else {
            fatalError("Couldn't find file '\(resource.rawValue).plist'")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Couldn't read file '\(resource.rawValue).plist'")
        }
        
        let decoder = PropertyListDecoder()
        guard let key = try? decoder.decode(APIKey.self, from: data) else {
            fatalError("Couldn't find keys in '\(resource.rawValue).plist'.")
        }
        return key
    }
}
