//
//  PaletteChoose.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 7/7/21.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var showPaletteEditor: Bool = false
        
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                chosenPalette = document.palette(after: chosenPalette)
            }, onDecrement: {
                chosenPalette = document.palette(before: chosenPalette)
            }, label: { EmptyView()} )
            Text(document.paletteNames[chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    showPaletteEditor = !showPaletteEditor
                }
                .popover(isPresented: $showPaletteEditor)  {
                    PaletteEditor(chosenPalette: $chosenPalette)
                        .environmentObject(document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var palletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Palette Editor for: ").font(.headline).padding()
            Text(document.paletteNames[chosenPalette] ?? "")
            Divider()
            Form {
                TextField("Palette Name", text: $palletteName, onEditingChanged: {
                    began in
                    if !began {
                        document.renamePalette(chosenPalette, to: palletteName)
                    }
                })
                TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: {
                    began in
                    if !began {
                        chosenPalette = document.addEmoji(emojisToAdd, toPalette: chosenPalette)
                        emojisToAdd = ""
                    }
                })
                Section(header: Text("Remove Emojis")) {
                    Grid(chosenPalette.map { String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: fontSize))
                                .onTapGesture {
                                chosenPalette = document.removeEmoji(emoji, fromPalette: chosenPalette)
                            }
                        }
                    .frame(height: height)
                }
            }
        }
        .onAppear {palletteName = document.paletteNames[chosenPalette] ?? ""}
    }
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    var fontSize: CGFloat = 40
}
