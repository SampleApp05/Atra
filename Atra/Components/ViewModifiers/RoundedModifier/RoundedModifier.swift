//
//  RoundedModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

struct RoundedModifier: ViewModifier {
    private let variant: Variant
    
    init(variant: Variant) {
        self.variant = variant
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: variant.topLeadingRadius,
                    bottomLeadingRadius: variant.bottomLeadingRadius,
                    bottomTrailingRadius: variant.bottomTrailingRadius,
                    topTrailingRadius: variant.topTrailingRadius
                )
            )
    }
}
