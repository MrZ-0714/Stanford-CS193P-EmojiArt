//
//  ContentView.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 6/16/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack() {
            ScrollView(.horizontal) {
                HStack() {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: 40))
                    }
                }
            }
            .padding(.horizontal)
        }
        
        Rectangle()
            .foregroundColor(.yellow)
            .edgesIgnoringSafeArea(.bottom)
    }
}

//extension String: Identifiable {
//    public var id: String { return self}
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(document: EmojiArtDocument)
//    }
//}
