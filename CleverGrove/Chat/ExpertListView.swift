//
//  ExpertListView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertListView: View {
    
    let experts: [ExpertProfile]
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill.badge.plus")
                            .foregroundColor(Color("Primary"))
                            .font(.title2)
                    }
                    
                    ScrollView() {
                        VStack(alignment: .leading, spacing: 5) {
                            
                            Divider()
                                .padding(.bottom, 20)
                            
                            VStack(spacing: 25) {
                                ForEach(experts) { expert in
                                    NavigationLink {
                                        ChatView(openAI: expert.openAI)
                                    } label: {
                                        ExpertSummary(expert: expert)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .navigationTitle("My Experts")
        }
    }
}

struct ExpertListView_Previews: PreviewProvider {
    static var previews: some View {
        let openAIKey = KeyStore.key(from: .openAI)
        let aiCoordinator = OpenAICoordinator(key: openAIKey.api_key, org: openAIKey.org_key)

        let experts = [ExpertProfile(image: "SampleProfile1", name: "George", description: "Personal recipes expert.", openAI: aiCoordinator),
                       ExpertProfile(image: "SampleProfile2", name: "Sarah", description: "Dungeons & Dragons expert.", openAI: aiCoordinator),
                       ExpertProfile(image: "SampleProfile3", name: "Imran", description: "Knows everything about my insurance documentation.", openAI: aiCoordinator)]
        ExpertListView(experts: experts)
    }
}
