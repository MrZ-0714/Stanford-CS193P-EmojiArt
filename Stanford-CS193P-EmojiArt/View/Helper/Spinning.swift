//
//  Spinning.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 7/6/21.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear{
                isVisible = true
            }
        
    }
}
