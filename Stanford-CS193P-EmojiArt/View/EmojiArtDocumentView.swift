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
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag{ return NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: document.backgroundImage)
                            .scaleEffect(zoomScale)
                            .offset(panOffset)
                    )
                    .gesture(doubleTapToZoom(in: geometry.size))
                    /*
                     5. Single-tapping on the background of your EmojiArt (i.e. single-tapping anywhere
                     except on an emoji) should deselect all emoji.
                     */
                    .onTapGesture { selectedEmojis.removeAll() }
                    
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
                            .background(Color.white)
                            /*
                             2. Support the selection of one or more of the emojis which have been dragged into
                             your EmojiArt document (i.e. you’re selecting the emojis in the document, not the ones
                             in the palette at the top). You can show which emojis are selected in any way you’d
                             like. The selection is not persistent (in other words, restarting your app will not
                             preserve the selection).
                             3. Tapping on an unselected emoji should select it.
                             4. Tapping on a selected emoji should unselect it.
                             */
                            .onTapGesture {
                                selectedEmojis.toggleSelection(of: emoji)
                            }
                            .gesture(isSelected(emoji) ? panSelectedEmojis(in: geometry.size) : nil)
                            .gesture(isSelected(emoji) ? zoomGesture() : nil)
                            .onLongPressGesture {
                                document.deleteEmoji(emoji)
                            }
                            //.onDrag({ return NSItemProvider(object: emoji.text as NSString) })
                            .overlay(
                                Circle()
                                    .stroke(Color.red ,lineWidth: 2.0)
                                    .opacity(isSelected(emoji) ? 1 : 0)
                            )
                            .position(position(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .gesture(panGesture())
                .gesture(zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = CGPoint(x: location.x, y: location.y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2 )
                    location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                    location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale )
                    
                    return drop(providers: providers, at: location)
                }
            }
        }
    }
    
    //MARK: - Zoom Gesture
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating( $gestureZoomScale ) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
                for emoji in selectedEmojis {
                    document.sacleEmoji(emoji, by: zoomScale)
                }
            }
            .onEnded { finalGestureScale in
                steadyStateZoomScale *= finalGestureScale
                for emoji in selectedEmojis {
                    document.sacleEmoji(emoji, by: zoomScale)
                }
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded{
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    //MARK: - Pan Gesture
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffest: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffest) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffest) { latestDragGestureValue, gesturePanOffest, transaction in
                gesturePanOffest = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State private var steadyStatePanOffsetForEmojis: CGSize = .zero
    @GestureState private var gesturePanOffestForEmojis: CGSize = .zero
    
    private var panOffsetForEmojis: CGSize {
        (steadyStatePanOffsetForEmojis + gesturePanOffestForEmojis) * zoomScale
    }
    
    private func panSelectedEmojis(in size: CGSize) -> some Gesture {
        DragGesture()
            .updating($gesturePanOffestForEmojis) { latestDragGestureValue, gesturePanOffestForEmojis, transaction in
                gesturePanOffestForEmojis = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffsetForEmojis = steadyStatePanOffsetForEmojis + (finalDragGestureValue.translation / zoomScale)
                for emoji in selectedEmojis {
                    let newLocation = newLocationForEmoji(for: emoji, in: size)
                    print(newLocation, panOffsetForEmojis, emoji)
                    withAnimation {
                        document.moveEmoji(emoji, to: newLocation)
                    }
                }
            }
    }
    
    private func newLocationForEmoji(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffsetForEmojis.width, y: location.y + panOffsetForEmojis.height)
        return location
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    //MARK: - Drop function
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    //MARK: - Emoji Selection
    @State private var selectedEmojis: Set<EmojiArt.Emoji> = []
    
    private func isSelected(_ emojiInput: EmojiArt.Emoji) -> Bool {
        for selectedEmoji in selectedEmojis {
            if emojiInput.id == selectedEmoji.id {
                return true
            }
        }
        return false
    }
    
    //MARK: - Parameters
    private let defaultEmojiSize: CGFloat = 40
}

extension EmojiArtDocumentView {
    func printKeyPositions() {
        print(steadyStatePanOffsetForEmojis,
              gesturePanOffestForEmojis,
              panOffsetForEmojis)
    }
}

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
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
