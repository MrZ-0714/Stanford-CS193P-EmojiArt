//
//  EmojiArtDocument.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 6/16/21.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject, Hashable, Equatable, Identifiable {
    let id: UUID
    
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let palette: String = "EMOJISPLACEHOLDER"
    private static let Untitled: String = "EmojiArtDocument.Untitled"
    
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
    private var autosaveCancellable: AnyCancellable?
    
    init(id: UUID? = nil ) {
        self.id = id ?? UUID()
        let defaultKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultKey)) ?? EmojiArt()
        
        //use publisher to achieve autosave and bind variables to VM.
        autosaveCancellable = $emojiArt.sink() { emojiArt in
            UserDefaults.standard.set(emojiArt.json, forKey: defaultKey)
        }
        fetchBackgroundImageData()
    }
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis}
    
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
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, to location: CGPoint) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x = Int(location.x)
            emojiArt.emojis[index].y = Int(location.y)
        }
    }
    
    func sacleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func deleteEmoji(_ emoji: EmojiArt.Emoji) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis.remove(at: index)
        }
    }
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            // put the url request to a background queue to avoid frozen app
            fetchImageCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage( data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
            fetchImageCancellable = publisher.assign(to: \.backgroundImage, on: self)
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    //Put setting the background image to the main queue as it will change the view
//                    //IOS only allow user to change the view from the main queue
//                    //changing view from a background queue could case issues to the app.
//                    DispatchQueue.main.async {
//                        // check if the url matches what the user last asked the app fetch from.
//                        if url == self.emojiArt.backgroundURL {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat {
        CGFloat(self.size)
    }
    
    var location: CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
