//
//  ScrollerModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 25.08.25.
//

import SwiftUI

struct ScrollerModifier<T: Hashable, Value: Equatable>: ViewModifier {
    let scrollID: T
    let value: Value
    let animated: Bool
    
    func body(content: Content) -> some View {
        ScrollViewReader { (scrollReader) in
            content
                .onChange(of: value) {
                    if animated {
                        withAnimation { scrollReader.scrollTo(scrollID) }
                    } else {
                        scrollReader.scrollTo(scrollID)
                    }
                }
        }
    }
}
