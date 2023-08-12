//
//  ContentView.swift
//  ChatBot
//
//  Created by Derek Gour on 2023-07-28.
//

import SwiftUI

struct ContentView: View {
//    @State var experts = PreviewSamples.experts
    
    var body: some View {
        ExpertListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
