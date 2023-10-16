//
//  URL-Extensions.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import Foundation

extension URL {
    /** A shortcut extension to URL type to retrieve the URL for the app's documents directory. */
    static var documents: URL {
        return FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
