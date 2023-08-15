//
//  DocumentCapsule.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentCapsule: View {
    
    @ObservedObject var document: CDDocument
    @Binding var trainingProgress: Double
    
    var body: some View {
        HStack {
            FileType(rawValue: document.filetype ?? "")?.image
                .resizable()
                .frame(width: 40, height: 48)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0)))
                .overlay(
                    RoundedRectangle(cornerSize: CGSize(width: 3.0, height: 3.0))
                        .strokeBorder(.white, lineWidth: 1)
                    )
            VStack(alignment: .leading) {
                Text(document.fileName ?? "")
                    .foregroundColor((DocumentStatus(rawValue: document.status ?? "") == .trained) ? Color.primary : Color.red)
                    .font(.headline)
                Text(document.status ?? "")
                    .foregroundColor((DocumentStatus(rawValue: document.status ?? "") == .trained) ? Color.secondary : Color.red)
                if DocumentStatus(rawValue:document.status ?? "") == .training {
                    ProgressView("Training…  \(Int(trainingProgress * 100))%", value: trainingProgress, total: 1.0)
                        .foregroundColor(Color.blue)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DocumentCapsule_Previews: PreviewProvider {
    static var previews: some View {
//        DocumentCapsule(document: PreviewSamples.documentTrained, trainingProgress: .constant(0.34))
        DocumentCapsule(document: PreviewSamples.documentTraining, trainingProgress: .constant(0.69))
    }
}
