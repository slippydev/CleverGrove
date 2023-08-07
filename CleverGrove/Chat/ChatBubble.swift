//
//  ChatBubble.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-07.
//

import SwiftUI

enum BubblePosition {
    case left
    case right
}

struct ChatBubble<Content>: View where Content: View {
    let position: BubblePosition
    let color : Color
    let content: () -> Content
    init(position: BubblePosition, color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.position = position
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            content()
                .padding(.all, 15)
                .foregroundColor(Color.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: position == .left ? -50 : -130))
                        .offset(x: position == .left ? -5 : 5)
                    ,alignment: position == .left ? .bottomLeading : .bottomTrailing)
        }
        .padding(position == .left ? .leading : .trailing , 15)
        .padding(position == .right ? .leading : .trailing , 60)
        .frame(width: UIScreen.main.bounds.width, alignment: position == .left ? .leading : .trailing)
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubble(position: .left, color: .blue, content: {
            Text("this is a text bubble")
        })
    }
}
