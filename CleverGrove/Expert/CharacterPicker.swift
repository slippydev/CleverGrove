//
//  CharacterPicker.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-15.
//

import SwiftUI

struct CharacterImage: View {
    let image: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 90, height: 90, alignment: .center)
            .overlay(isSelected ? Capsule().stroke(Color.blue, lineWidth: 10) : Capsule().stroke(Color.gray, lineWidth: 3))
            .mask {
                Circle()
            }
    }
}

struct CharacterPicker: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedIndex = -1
    @State private var images: [String: Bool]
    @Binding var selectedImage: String
    
    init(selectedImage: Binding<String>) {
        _images = State(initialValue: randomNames.reduce(into: [:]) { dict, image in
            dict[image] = false
        })
        _selectedImage = selectedImage
    }
    
    let columns = [
        GridItem(.fixed(90), spacing: 20),
        GridItem(.fixed(90), spacing: 20),
        GridItem(.fixed(90), spacing: 20)
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button() {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                }
                .padding([.horizontal], 20)
                .padding([.vertical], 10)
            }
            
            Text("Select a Profile Image For Your Expert")
                .font(.title)
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(Array(images.keys.sorted()), id: \.self) { image in
                        CharacterImage(image: image, isSelected: .constant(selectedImage == image))
                            .onTapGesture {
                                selectImage(image: image)
                            }
                    }
                }
            }
        }
    }
    
    func selectImage(image: String) {
        // Deselect all first
        for key in images.keys {
            images[key] = false
        }
        images[image] = true
        selectedImage = image
    }
}

struct CharacterPicker_Previews: PreviewProvider {
    static var previews: some View {
        CharacterPicker(selectedImage: .constant("Knight"))
    }
}
