//
//  SizeTrackerModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 8.09.25.
//

import SwiftUI

struct SizeTrackerModifier: ViewModifier {
    @Binding var size: CGSize
    
    init(size: Binding<CGSize>) {
        self._size = size
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { (reader) in
                    Color.clear
                        .onAppear {
                            size = reader.size
                        }
                }
            }
    }
}
