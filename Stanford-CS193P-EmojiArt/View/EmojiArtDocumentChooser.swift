//
//  EmojiArtDocumentChooser.swift
//  Stanford-CS193P-EmojiArt
//
//  Created by Zimo Zhao on 7/8/21.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                            .navigationBarTitle(self.store.name(for: document))
                    ) {
                        Text(store.name(for: document))
                        }
                }
            }
            .navigationBarTitle(self.store.name)
            .navigationBarItems(
                leading: Button(
                    action: { self.store.addDocument() },
                    label: { Image(systemName: "plus").imageScale(.large) }
                )
            )
        }


    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
