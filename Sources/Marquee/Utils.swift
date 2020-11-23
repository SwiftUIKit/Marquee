//
//  Utils.swift
//  
//
//  Created by CatchZeng on 2020/11/23.
//

import Foundation
import CoreGraphics
import SwiftUI

struct DurationKey: EnvironmentKey {
    static var defaultValue: Double = 2.0
}

struct AutoreversesKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct DirectionKey: EnvironmentKey {
    static var defaultValue: MarqueeDirection = .right2left
}

extension EnvironmentValues {
    var marqueeDuration: Double {
        get {self[DurationKey.self]}
        set {self[DurationKey.self] = newValue}
    }
    
    var marqueeAutoreverses: Bool {
        get {self[AutoreversesKey.self]}
        set {self[AutoreversesKey.self] = newValue}
    }
    
    var marqueeDirection: MarqueeDirection {
        get {self[DirectionKey.self]}
        set {self[DirectionKey.self] = newValue}
    }
}

public extension View {
    func marqueeDuration(_ duration: Double) -> some View {
        environment(\.marqueeDuration, duration)
    }
    
    func marqueeAutoreverses(_ autoreverses: Bool) -> some View {
        environment(\.marqueeAutoreverses, autoreverses)
    }
    
    func marqueeDirection(_ direction: MarqueeDirection) -> some View {
        environment(\.marqueeDirection, direction)
    }
}

struct GeometryBackground: View {
    var body: some View {
        GeometryReader { geometry in
            return Color.clear.preference(key: WidthKey.self, value: geometry.size.width)
        }
    }
}

struct WidthKey: PreferenceKey {
    static var defaultValue = CGFloat(0)

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

    typealias Value = CGFloat
}

extension Animation {
    static var instant: Animation {
        return .linear(duration: 0.01)
    }
}

// Refference:  https://swiftui-lab.com/swiftui-animations-part2/

extension View {
    func myOffset(x: CGFloat, y: CGFloat) -> some View {
        return modifier(_OffsetEffect(offset: CGSize(width: x, height: y)))
    }

    func myOffset(_ offset: CGSize) -> some View {
        return modifier(_OffsetEffect(offset: offset))
    }
}

struct _OffsetEffect: GeometryEffect {
    var offset: CGSize
    
    var animatableData: CGSize.AnimatableData {
        get { CGSize.AnimatableData(offset.width, offset.height) }
        set { offset = CGSize(width: newValue.first, height: newValue.second) }
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: offset.width, y: offset.height))
    }
}
