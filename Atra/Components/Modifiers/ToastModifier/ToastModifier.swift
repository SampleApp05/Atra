//
//  ToastModifier.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    typealias Config = ToastView.Config
    
    @Binding private var isPresented: Bool
    @State private var dragGestureOffset = CGSize.zero
    
    private let config: Config
    private let duration: TimeInterval
    private let position: Position
    private let isDismissable: Bool
    private let action: VoidClosure?
    
    init(
        isPresented: Binding<Bool>,
        config: Config,
        duration: TimeInterval,
        position: Position,
        isDismissable: Bool,
        action: VoidClosure?
    ) {
        self._isPresented = isPresented
        self.config = config
        self.duration = duration
        self.position = position
        self.isDismissable = isDismissable
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.overlay(alignment: position.alignment) {
            if isPresented {
                ToastView(config: config)
                    .task {
                        if isDismissable {
                            try? await Task.sleep(nanoseconds: duration.inNanoSeconds)
                            guard isPresented else { return }
                            isPresented = false
                        }
                    }
                    .gesture (
                        DragGesture(minimumDistance: 5)
                            .onChanged { (gesture) in
                                dragGestureOffset = gesture.translation
                            }
                            .onEnded { (_) in
                                if isDismissable && abs(dragGestureOffset.height) > 50 {
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        action?()
                        
                        if isDismissable {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: position.transitionEdge).combined(with: .opacity),
                            removal: .move(edge: position.transitionEdge).combined(with: .opacity)
                        )
                    )
                    .padding(position == .top ? .top : .bottom, 5)
            }
        }
    }
}

#Preview {
    StatePreviewWrapper(state: true) { (state) in
        Color.black.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                state.wrappedValue.toggle()
            }
            .toast(
                isPresented: state,
                config: .init(
                    title: "Test Toast",
                    message: "This is a test toast message.",
                    image: Image(systemName: "bell.fill"),
                ),
                duration: 10.0,
                position: .top,
                action: { print("Toast action triggered") }
            )
            .animation(.easeInOut, value: state.wrappedValue)
    }
}
