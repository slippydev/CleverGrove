//
//  TypingIndicator.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-15.
//

import SwiftUI

struct TypingBall: View {
    @Binding var color : Color
    @Binding var height: CGFloat
    private let width: CGFloat = 10
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Capsule()
                .foregroundColor(color)
                .frame(width: width, height: height)
        }
    }
}

struct TypingIndicator: View {
    @State var colors = [Color.black, Color.black, Color.black]
    @State var heights: [CGFloat] = [10, 10, 10]
    let duration: Double = 1.0
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ForEach(0..<3) { index in
                TypingBall(color: $colors[index], height: $heights[index])
                    .animateForever(autoreverses: true,
                                    duration: duration,
                                    delay: Double(index) * duration/3.0)
                {
                    colors[index] = Color.white
                }
            }
        }
    }
}

struct TypingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        TypingIndicator()
    }
}

