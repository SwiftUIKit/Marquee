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

struct DelayKey: EnvironmentKey {
    static var defaultValue: Double = 0.0
}

struct AutoreversesKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct DirectionKey: EnvironmentKey {
    static var defaultValue: MarqueeDirection = .right2left
}

struct StopWhenNotFitKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct AlignmentKey: EnvironmentKey {
    static var defaultValue: HorizontalAlignment = .leading
}

struct BoundaryKey: EnvironmentKey {
    static var defaultValue: MarqueeBoundary = .outer
}

extension EnvironmentValues {
    var marqueeDuration: Double {
        get {self[DurationKey.self]}
        set {self[DurationKey.self] = newValue}
    }

    var marqueeDelay: Double {
        get {self[DelayKey.self]}
        set {self[DelayKey.self] = newValue}
    }
    
    var marqueeAutoreverses: Bool {
        get {self[AutoreversesKey.self]}
        set {self[AutoreversesKey.self] = newValue}
    }
    
    var marqueeDirection: MarqueeDirection {
        get {self[DirectionKey.self]}
        set {self[DirectionKey.self] = newValue}
    }
    
    var marqueeWhenNotFit: Bool {
        get {self[StopWhenNotFitKey.self]}
        set {self[StopWhenNotFitKey.self] = newValue}
    }
    
    var marqueeIdleAlignment: HorizontalAlignment {
        get {self[AlignmentKey.self]}
        set {self[AlignmentKey.self] = newValue}
    }

    var marqueeBoundary: MarqueeBoundary {
        get {self[BoundaryKey.self]}
        set {self[BoundaryKey.self] = newValue}
    }
}

public extension View {
    /// Sets the marquee animation duration to the given value.
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeDuration(3.0)
    ///
    /// - Parameters:
    ///   - duration: Animation duration, default is `2.0`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeDuration(_ duration: Double) -> some View {
        environment(\.marqueeDuration, duration)
    }

    /// Sets the marquee animation delay to the given value.
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeDelay(0.5)
    ///
    /// - Parameters:
    ///   - delay: Animation delay, default is `0.0`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeDelay(_ delay: Double) -> some View {
        environment(\.marqueeDelay, delay)
    }
    
    /// Sets the marquee animation autoreverses to the given value.
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeAutoreverses(true)
    ///
    /// - Parameters:
    ///   - autoreverses: Animation autoreverses, default is `false`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeAutoreverses(_ autoreverses: Bool) -> some View {
        environment(\.marqueeAutoreverses, autoreverses)
    }
    
    /// Sets the marquee animation direction to the given value.
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeDirection(.right2left)
    ///
    /// - Parameters:
    ///   - direction: `MarqueeDirection` enum, default is `right2left`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeDirection(_ direction: MarqueeDirection) -> some View {
        environment(\.marqueeDirection, direction)
    }
    
    /// Stop the marquee animation when the content view is not fit`(contentWidth < marqueeWidth)`.
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeWhenNotFit(true)
    ///
    /// - Parameters:
    ///   - stopWhenNotFit: Stop the marquee animation when the content view is not fit(`contentWidth <  marqueeWidth`), default is `false`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeWhenNotFit(_ stopWhenNotFit: Bool) -> some View {
        environment(\.marqueeWhenNotFit, stopWhenNotFit)
    }
    
    /// Sets the marquee alignment  when idle(stop animation).
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeIdleAlignment(.center)
    ///
    /// - Parameters:
    ///   - alignment: Alignment  when idle(stop animation), default is `.leading`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeIdleAlignment(_ alignment: HorizontalAlignment) -> some View {
        environment(\.marqueeIdleAlignment, alignment)
    }

    /// Sets the marquee boundaries to the given value
    ///
    ///     Marquee {
    ///         Text("Hello World!")
    ///     }.marqueeBoundary(.inner)
    ///
    /// - Parameters:
    ///   - boundary: Boundary when the animation will be finished. See `MarqueeBoundary` for possible values, default is `.outer`.
    ///
    /// - Returns: A view that has the given value set in its environment.
    func marqueeBoundary(_ boundary: MarqueeBoundary) -> some View {
        environment(\.marqueeBoundary, boundary)
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
