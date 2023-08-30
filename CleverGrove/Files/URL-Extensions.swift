//
//  URL-Extensions.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-29.
//

import Foundation

extension URL {
    static var documents: URL {
        return FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
