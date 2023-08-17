//
//  ChatTextField.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-17.
//

import SwiftUI

struct ChatTextField: View {
    
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 35
    var buttonAction: () -> ()
    var body: some View {
        
        ZStack(alignment: .trailing) {
            Text(string)
//                .font(.system(.body))
                .font(.system(size: 19, design: .rounded))
                .foregroundColor(.clear)
                .padding(.vertical, 10)
                .padding(.leading, 10)
                .padding(.trailing, 35)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $string)
//                .font(.system(.body))
                .font(.system(size: 19, design: .rounded))
                .frame(height: max(40, textEditorHeight))
                .padding(.leading, 10)
                .padding(.trailing, 35)

            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray, lineWidth: 0.7)
                .foregroundColor(.clear)
                .frame(height: max(43, textEditorHeight+3))
                .shadow(radius: 1.0)
            
            Button() {
                buttonAction()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .frame(alignment: .center)
            .padding([.trailing], 10)
        }
        .onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
    }
}


struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}


struct ChatTextField_Previews: PreviewProvider {
    static var previews: some View {
        ChatTextField(string: .constant("Hello"), buttonAction: {})
    }
}
