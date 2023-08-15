//
//  DocumentList.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-11.
//

import SwiftUI

struct DocumentList: View {
    @ObservedObject var expert: CDExpert
    @Binding var trainingProgress: Double
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                ForEach(expert.documentsAsArray) { document in
                    NavigationLink {
                        // Link to document
                    } label: {
                        DocumentCapsule(document: document, trainingProgress: $trainingProgress)
                    }
                }
            }
        }
    }
}


//struct DocumentList_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentList(documents: .constant(PreviewSamples.documents))
//    }
//}
