//
//  EmojiArtDocument.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 6/16/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static let palette: String = "EMOJIS"
    
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
    //MARK: - Intent(s):
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x = Int(offset.width)
            emojiArt.emojis[index].y = Int(offset.height)
        }
    }
    
    func sacleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
    }
}
