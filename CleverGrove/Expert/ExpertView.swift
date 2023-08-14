//
//  ExpertView.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct ExpertView: View {
    @ObservedObject var expert: CDExpert
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var image: Image = Image(systemName: "questionmark.square.dashed")
    @State private var documents = [CDDocument]()
    
    @State private var showingEditView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        ExpertProfileImage(image: Image(expert.image ?? ""), geo: geometry)
                        Divider()
                        Text(name)
                            .font(.title.bold())
                            .padding(.bottom, 5)
                        Text(description)
                            .padding(.horizontal, 20)
                    }
                    Divider()
                    Text("Training Documents")
                        .font(.title2)
                        .padding([.bottom, .top], 10)
                        .foregroundColor(Color("Primary"))
                    DocumentList(expert: expert)
                        .padding(.bottom)
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button() {
                        showingEditView = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}

//struct ExpertView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpertView(expert: .constant(PreviewSamples.expert))
//    }
//}
