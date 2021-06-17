//
//  EmojiArt.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 6/16/21.
//

import Foundation

struct EmojiArt: Codable {
    var backgroundURL: URL?
    
    var emojis = [Emoji]()
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    struct Emoji: Identifiable, Codable {
        let id: Int
        let text: String
        var x: Int //offset from the center
        var y: Int //offset from the center
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    private var uniqueEmojiId = 0
    
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    init() {}
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: x, y: y, size: size))
    }
}
