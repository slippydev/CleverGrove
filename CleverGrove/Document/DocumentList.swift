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
        VStack(alignment: .leading) {
            List {
                ForEach(expert.documentsAsArray) { document in
                    NavigationLink {
                        // Link to document
                    } label: {
                        DocumentCapsule(document: document, trainingProgress: $trainingProgress)
                    }
                    .swipeActions() {
                        Button(role: .destructive) {
                            remove(document: document, from: expert)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
    }
    
    func remove(document: CDDocument, from expert: CDExpert) {
        expert.removeFromDocuments(document)
        DataController.shared.save()
    }
}


struct DocumentList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentList(expert: PreviewSamples.expert, trainingProgress: .constant(1.0))
    }
}
