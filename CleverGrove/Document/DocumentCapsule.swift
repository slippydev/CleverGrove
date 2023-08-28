//
//  DocumentCapsule.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct DocumentCapsule: View {
    
    @ObservedObject var document: CDDocument
    @ObservedObject var coordinator = DocumentCoordinator.shared
    
    var progress: Double {
        coordinator.jobs[document.id!] ?? 0
    }
    
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
                    .foregroundColor((DocumentStatus(rawValue: document.status ?? "") == .training) ? Color.red : Color.primary)
                    .font(.headline)
                
                if DocumentStatus(rawValue:document.status ?? "") == .training {
                    ProgressView("Training…  \(Int(progress * 100))%", value: progress, total: 1.0)
                        .foregroundColor(Color.blue)
                } else {
                    Text(document.status ?? "")
                        .foregroundColor((DocumentStatus(rawValue: document.status ?? "") == .training) ? Color.red : Color.primary)
                        .opacity((DocumentStatus(rawValue: document.status ?? "") == .untrained) ? 0 : 1.0) // hide if untrained
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DocumentCapsule_Previews: PreviewProvider {
    static var previews: some View {
//        DocumentCapsule(document: PreviewSamples.documentTrained, trainingProgress: .constant(0.34))
        DocumentCapsule(document: PreviewSamples.documentTraining)
    }
}
