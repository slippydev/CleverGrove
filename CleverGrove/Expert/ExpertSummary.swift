//
//  ExpertSummary.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertSummary: View {
    
    @ObservedObject var expert: CDExpert

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                Image(expert.image ?? "Person")
                    .resizable()
                    .frame(width: 75, height: 75, alignment: .topLeading)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding([.top, .bottom, .leading], 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(expert.name ?? "")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                    
                    Text(expert.desc ?? "")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // Allow unlimited lines for description
                        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                }
                .padding([.vertical, .horizontal], 5)
            }
        }
    }
}


struct ExpertSummary_Previews: PreviewProvider {
    static var previews: some View {
        let expert = PreviewSamples.expert
        ExpertSummary(expert: expert)
    }
}
