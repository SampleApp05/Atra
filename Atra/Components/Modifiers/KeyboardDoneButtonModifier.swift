//
//  KeyboardDoneButtonModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 23.08.25.
//


import SwiftUI

struct KeyboardDoneButtonModifier: ViewModifier {
    private let title: String
    private let completion: VoidClosure
    
    init(title: String, completion: @escaping VoidClosure) {
        self.title = title
        self.completion = completion
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button(title) {
                        withAnimation {
                            completion()
                        }
                    }
                }
            }
    }
}
