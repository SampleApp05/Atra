//
//  StatePreviewWrapper.swift
//  Atra
//
//  Created by Daniel Velikov on 11.07.25.
//

import SwiftUI

struct StatePreviewWrapper<Value, Content: View>: View {
    @State private var state: Value
    private var content: (Binding<Value>) -> Content
    
    init(state: Value, content: @escaping (Binding<Value>) -> Content) {
        self.state = state
        self.content = content
    }
    
    var body: some View {
        content($state)
    }
}
