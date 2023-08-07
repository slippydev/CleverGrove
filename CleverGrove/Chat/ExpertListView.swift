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
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            VStack {
                
                HStack {
                    Text("My Experts")
                        .fontWeight(.semibold)
                        .font(.largeTitle)
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
                                ExpertSummary(expert: expert)
                            }
                        }
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
    }
}

struct ExpertListView_Previews: PreviewProvider {
    static var previews: some View {
        let experts = [ExpertProfile(image: "SampleProfile1", name: "George", description: "Personal recipes expert."),
                       ExpertProfile(image: "SampleProfile2", name: "Sarah", description: "Dungeons & Dragons expert."),
                       ExpertProfile(image: "SampleProfile3", name: "Imran", description: "Knows everything about my insurance documentation.")]
        ExpertListView(experts: experts)
    }
}
