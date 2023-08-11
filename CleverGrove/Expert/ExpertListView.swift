//
//  ExpertListView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

struct ExpertListView: View {
    
    @Binding var experts: [ExpertProfile]
    @State private var isShowingEditExpertSheet = false
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.name)
    ]) var cachedExperts: FetchedResults<CDExpert>
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Button() {
                            isShowingEditExpertSheet = true
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
                                ForEach(cachedExperts) { cachedExpert in
                                    let expert = cachedExpert.expertProfile()
                                    NavigationLink {
                                        ChatView(expert: .constant(expert))
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
            .sheet(isPresented: $isShowingEditExpertSheet) {
                EditExpertView(expert: ExpertProfile.emptyExpert())
            }
        }
    }
    
    
    
//    func getEmbeddings() async {
//        let embeddings = await aiCoordinator.getEmbeddings(for: SampleText.text)
//    }
}

struct ExpertListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpertListView(experts: .constant(PreviewSamples.experts))
    }
}
