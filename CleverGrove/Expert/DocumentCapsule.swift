//
//  DocumentCapsule.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentInfo: Identifiable {
    let id = UUID()
    let image: Image
    let fileName: String
    let status: String
}

struct DocumentCapsule: View {
    
    let info: DocumentInfo
    
    var body: some View {
        HStack {
            info.image
                .resizable()
                .frame(width: 40, height: 48)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0)))
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0))
                        .strokeBorder(.white, lineWidth: 1)
                    )
            VStack(alignment: .leading) {
                Text(info.fileName)
                    .foregroundColor(Color("Primary"))
                    .font(.headline)
                Text(info.status)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct DocumentCapsule_Previews: PreviewProvider {
    static var previews: some View {
        let info = DocumentInfo(image: Image(systemName: "doc.plaintext"), fileName: "Hope Inhumanity Rules", status: "Trained")
        DocumentCapsule(info: info)
    }
}
