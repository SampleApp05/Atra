//
//  BorderModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 24.08.25.
//

import SwiftUI

struct BorderModifier<S: ShapeStyle>: ViewModifier {
    let fillStyle: S
    let strokeStyle: StrokeStyle
    let radiusStyle: RadiusStyle
    
    init(fillStyle: S, strokeStyle: StrokeStyle, radiusStyle: RadiusStyle, ) {
        self.fillStyle = fillStyle
        self.strokeStyle = strokeStyle
        self.radiusStyle = radiusStyle
    }
    
    func body(content: Content) -> some View {
        content
            .rounded(radiusStyle)
            .overlay {
                UnevenRoundedRectangle(style: radiusStyle)
                    .stroke(
                        fillStyle,
                        style: strokeStyle
                    )
            }
    }
}
