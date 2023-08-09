//
//  ExpertProfileImage.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-09.
//

import SwiftUI

struct ExpertProfileImage: View {
    let image: Image
    let geo: GeometryProxy
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(maxWidth: geo.size.width * 0.3)
    }
}

struct ExpertProfileImage_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { geo in
            ExpertProfileImage(image: Image("SampleProfile1"), geo: geo)
        }
    }
}
