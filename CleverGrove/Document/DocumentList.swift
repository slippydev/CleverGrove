//
//  DocumentList.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//

import SwiftUI

struct DocumentList: View {
    @Binding var documents: [DocumentInfo]
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                ForEach($documents) { $document in
                    NavigationLink {
                        // Link to document
                    } label: {
                        DocumentCapsule(document: $document)
                    }
                }
            }
        }
    }
}


struct DocumentList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentList(documents: .constant(PreviewSamples.documents))
    }
}
