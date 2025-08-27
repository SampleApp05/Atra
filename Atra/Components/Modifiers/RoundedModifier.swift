//
//  RoundedModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

struct RoundedModifier: ViewModifier {
    private let style: RadiusStyle
    
    init(style: RadiusStyle) {
        self.style = style
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(
                UnevenRoundedRectangle(style: style)
            )
    }
}
