//
//  SelectionBox.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct SelectionBox: View {
    let geo: GeometryProxy
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .strokeBorder(style: StrokeStyle(lineWidth: 5, dash: [5.0, 3.0], dashPhase: 2))
                .frame(maxWidth: geo.size.width * 0.3)
                .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))).opacity(0.1)
            Image(systemName: "plus.viewfinder")
                .resizable(resizingMode: .stretch)
                .frame(maxWidth: geo.size.width * 0.1, maxHeight: geo.size.width * 0.1)
                .foregroundColor(.gray)
        }
    }
}

struct SelectionBox_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            SelectionBox(geo: geo)
        }
    }
}
