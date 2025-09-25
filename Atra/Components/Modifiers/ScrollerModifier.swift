//
//  ScrollerModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 25.08.25.
//

import SwiftUI

struct ScrollerModifier<T: Hashable, Value: Equatable>: ViewModifier, Equatable {
    private let scrollID: T
    private let value: Value
    private let animated: Bool
    
    init(scrollID: T, value: Value, animated: Bool) {
        self.scrollID = scrollID
        self.value = value
        self.animated = animated
    }
    
    func body(content: Content) -> some View {
        ScrollViewReader { (scrollReader) in
            content
                .onChange(of: value) {
                    if animated {
                        withAnimation { scrollReader.scrollTo(scrollID) }
                    } else {
                        scrollReader.scrollTo(scrollID, anchor: .center)
                    }
                }
        }
    }
}
