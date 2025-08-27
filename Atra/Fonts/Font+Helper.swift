//
//  Font+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 21.08.25.
//

import SwiftUI

extension Font {
    enum Variant: String {
        case primary = "SpaceGrotesk"
        case secondary = "IBMPlexSans"
    }
    
    enum FontWeight: String {
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
    }
    
    enum Size: Double {
        case largeTitle = 34
        case title = 24
        case title3 = 20
        case headline = 18
        case body = 16
        case subheadline = 14
        case caption = 12
        
        var relativeFont: TextStyle {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .title
            case .title3: .title3
            case .headline: .headline
            case .body: .body
            case .subheadline: .subheadline
            case .caption: .caption
            }
        }
    }
}
