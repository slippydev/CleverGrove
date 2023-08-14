//
//  ChatViewHeader.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-14.
//

import SwiftUI

struct ChatViewHeader: View {
    @ObservedObject var expert: CDExpert
    
    var body: some View {
        HStack(alignment: .top) {
            Image(expert.image ?? "")
                .resizable()
                .frame(width: 50, height: 50, alignment: .topLeading)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding([.top], 5)
            VStack(alignment: .leading, spacing: 3) {
                Spacer()
                Text(expert.name ?? "")
                    .frame(height: 30, alignment: .bottom)
                Spacer()
            }
        }
        .frame(height:60)
    }
}

//struct ChatViewHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatViewHeader(name: .constant("Bob"), image: .constant("SampleProfile3"))
//    }
//}
