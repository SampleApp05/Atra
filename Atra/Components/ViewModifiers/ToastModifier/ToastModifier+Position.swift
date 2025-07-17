//
//  ToastModifier+Position.swift
//  Atra
//
//  Created by Daniel Velikov on 11.07.25.
//

import SwiftUI

extension ToastModifier {
    enum Position {
        case top
        case bottom
        
        var alignment: Alignment {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }
        
        var transitionEdge: Edge {
            switch self {
            case .top:
                return .top
            case .bottom:
                return .bottom
            }
        }
    }
}
