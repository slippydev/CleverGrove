//
//  DocumentCapsule.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentCapsule: View {
    
    @Binding var document: DocumentInfo
    
    var body: some View {
        HStack {
            document.image
                .resizable()
                .frame(width: 40, height: 48)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0)))
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0))
                        .strokeBorder(.white, lineWidth: 1)
                    )
            VStack(alignment: .leading) {
                Text(document.fileName)
                    .foregroundColor(Color("Primary"))
                    .font(.headline)
                Text(document.status.rawValue)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct DocumentCapsule_Previews: PreviewProvider {
    static var previews: some View {
        DocumentCapsule(document: .constant(PreviewSamples.document))
    }
}
