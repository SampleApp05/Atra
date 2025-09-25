//
//  View+Modifiers.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

extension View {
    func trackSize(_ size: Binding<CGSize>) -> some View {
        modifier(SizeTrackerModifier(size: size))
    }
    
    func rounded(_ style: RadiusStyle) -> some View {
        modifier(RoundedModifier(style: style))
    }
    
    func bordered<S: ShapeStyle>(
        fillStyle: S,
        strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1),
        radiusStyle: RadiusStyle = .all(10)
    ) -> some View {
        modifier(
            BorderModifier(
                fillStyle: fillStyle,
                strokeStyle: strokeStyle,
                radiusStyle: radiusStyle
            )
        )
    }
    
    func font(_ variant: Font.Variant, size: Font.Size, weight: Font.FontWeight = .regular) -> some View {
        let fontName = variant.rawValue + "-" + weight.rawValue
        
        return font(
            .custom(
                fontName,
                size: size.rawValue,
                relativeTo: size.relativeFont,
            )
        )
    }
    
    func keyboardDoneButton(title: String = "Done", completion: @escaping VoidClosure) -> some View {
        modifier(KeyboardDoneButtonModifier(title: title, completion: completion))
    }
    
    func scrollable(
        _ axes: Axis.Set = .vertical,
        indicatorVisibility: ScrollIndicatorVisibility = .hidden,
        bounceBehaviour: ScrollBounceBehavior = .basedOnSize,
        scrollClipDisabled: Bool = true
    ) -> some View {
        modifier(
            ScrollableModifier(
                axes,
                indicatorVisibility: indicatorVisibility,
                bounceBehaviour: bounceBehaviour,
                scrollClipDisabled: scrollClipDisabled
            )
        )
    }
    
    func scroll<ID: Hashable, Value: Equatable>(
        to id: ID,
        on value: Value,
        animated: Bool = true
    ) -> some View {
        modifier(ScrollerModifier(scrollID: id, value: value, animated: animated))
    }
    
    func toast(
        isPresented: Binding<Bool>,
        config: ToastView.Config,
        duration: TimeInterval = GlobalConstants.notificationDuration,
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
