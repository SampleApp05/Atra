//
//  UnevenRoundedRectangle+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 24.08.25.
//

import SwiftUI

extension UnevenRoundedRectangle {
    init(style: RadiusStyle) {
        self.init(
            topLeadingRadius: style.topLeadingRadius,
            bottomLeadingRadius: style.bottomLeadingRadius,
            bottomTrailingRadius: style.bottomTrailingRadius,
            topTrailingRadius: style.topTrailingRadius
        )
    }
}
