//
//  ExpertListView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertListView: View {
    
    @Binding var experts: [ExpertProfile]
//    @State var expert: ExpertProfile
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Button() {
                            Task {
                                await getEmbeddings()
                            }
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(Color("Primary"))
                                .font(.title2)
                        }
                    }
                    
                    ScrollView() {
                        VStack(alignment: .leading, spacing: 5) {
                            
                            Divider()
                                .padding(.bottom, 20)
                            
                            VStack(spacing: 25) {
                                ForEach($experts) { $expert in
                                    NavigationLink {
                                        ChatView(expert: $expert)
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
    
    func getEmbeddings() async {
        let embeddings = await experts[0].openAI.getEmbeddings(for: SampleText.text)
    }
}

struct ExpertListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpertListView(experts: .constant(PreviewSamples.experts))
    }
}
