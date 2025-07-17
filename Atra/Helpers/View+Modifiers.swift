//
//  View+Modifiers.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

extension View {
    func rounded(_ variant: RoundedModifier.Variant) -> some View {
        modifier(RoundedModifier(variant: variant))
    }
    
    func toast(
        isPresented: Binding<Bool>,
        config: ToastView.Config,
        duration: TimeInterval,
        position: ToastModifier.Position = .top,
        isDismissable: Bool = true,
        action: VoidClosure? = nil
    ) -> some View {
        modifier(
            ToastModifier(
                isPresented: isPresented,
                config: config,
                duration: duration,
                position: position,
                isDismissable: isDismissable,
                action: action
            )
        )
    }
}
