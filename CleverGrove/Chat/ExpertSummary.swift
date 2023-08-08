//
//  ExpertSummary.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertSummary: View {
    
    var expert: ExpertProfile
    
    var body: some View {
        HStack {
            Image(expert.image ?? "")
                .resizable()
                .background( Color("BackgroundInverted").opacity(0.05))
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 8) {
                HStack{
                    Text(expert.name)
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                }
                
                Text(expert.description)
                    .foregroundColor(Color("BackgroundInverted").opacity(0.5))
                    .lineLimit(5)
                Divider()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 10)
        }
    }
}

struct ExpertSummary_Previews: PreviewProvider {
    static var previews: some View {
        let openAIKey = KeyStore.key(from: .openAI)
        let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)

        let expert = ExpertProfile(image: "SampleProfile1", name: "Bobby", description: "Dungeons & Dragons expert", openAI: aiCoordinator)
        ExpertSummary(expert: expert)
    }
}
