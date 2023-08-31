//
//  ChatViewHeader.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-14.
//

import SwiftUI

struct ChatViewHeader: View {
    @ObservedObject var expert: CDExpert
    @State private var isShowingEditExpert = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image(expert.image ?? "")
                .resizable()
                .frame(width: 45, height: 45, alignment: .topLeading)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding([.top, .bottom], 5)
            VStack(alignment: .leading, spacing: 3) {
                Spacer()
                Text(expert.name ?? "")
                    .frame(height: 30, alignment: .center)
                    .fontWeight(.bold)
                Spacer()
            }
        }
        .frame(height:60)
        .onTapGesture {
            isShowingEditExpert = true
        }
        .sheet(isPresented: $isShowingEditExpert) {
            EditExpertView(expert: expert)
        }
    }
}

struct ChatViewHeader_Previews: PreviewProvider {
    static var previews: some View {
        ChatViewHeader(expert: PreviewSamples.expert)
    }
}
