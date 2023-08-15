//
//  View-Extensions.swift
//  CleverGrove
//
//  Created by Derek Gour on 2023-08-15.
//

import SwiftUI

extension View {
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

extension View {
    func animateForever(autoreverses: Bool = false,
                        duration: Double = 1.0,
                        delay: Double = 0.0,
                        _ action: @escaping () -> Void) -> some View {
        let animation = Animation
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: autoreverses)
            .delay(delay)

        return onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}
