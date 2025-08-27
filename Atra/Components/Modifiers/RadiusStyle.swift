//
//  RadiusStyle.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

enum RadiusStyle {
    case all(Double)
    case top(Double)
    case bottom(Double)
    case leading(Double)
    case trailing(Double)
    
    var topLeadingRadius: Double {
        switch self {
        case .all(let radius), .top(let radius), .leading(let radius):
            return radius
        default:
            return 0
        }
    }
    
    var bottomLeadingRadius: Double {
        switch self {
        case .all(let radius), .bottom(let radius), .leading(let radius):
            return radius
        default:
            return 0
        }
    }
    
    var bottomTrailingRadius: Double {
        switch self {
        case .all(let radius), .bottom(let radius), .trailing(let radius):
            return radius
        default:
            return 0
        }
    }
    
    var topTrailingRadius: Double {
        switch self {
        case .all(let radius), .top(let radius), .trailing(let radius):
            return radius
        default:
            return 0
        }
    }
}

