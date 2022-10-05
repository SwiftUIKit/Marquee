//
//  Marquee.swift
//
//
//  Created by CatchZeng on 2020/11/23.
//

import SwiftUI

public enum MarqueeDirection {
    case right2left
    case left2right
}

public enum MarqueeBoundary {
    /// Keeps the content visible and uses the inner boundary for the animation.
    case inner
    /// Moves the content outside of the view and uses the outer boundary for the animation.
    case outer
}

private enum MarqueeState {
    case idle
    case ready
    case animating
}

public struct Marquee<Content> : View where Content : View {
    @Environment(\.marqueeDuration) var duration
    @Environment(\.marqueeDelay) var delay
    @Environment(\.marqueeAutoreverses) var autoreverses: Bool
    @Environment(\.marqueeDirection) var direction: MarqueeDirection
    @Environment(\.marqueeWhenNotFit) var stopWhenNotFit: Bool
    @Environment(\.marqueeIdleAlignment) var idleAlignment: HorizontalAlignment
    @Environment(\.marqueeBoundary) var boundary: MarqueeBoundary
    
    private var content: () -> Content
    @State private var state: MarqueeState = .idle
    @State private var contentWidth: CGFloat = 0
    @State private var isAppear = false
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { proxy in
            VStack {
                if isAppear {
                    content()
                        .background(GeometryBackground())
                        .fixedSize()
                        .myOffset(x: offsetX(proxy: proxy), y: 0)
                        .frame(maxHeight: .infinity)
                } else {
                    Text("")
                }
            }
            .onPreferenceChange(WidthKey.self, perform: { value in
                self.contentWidth = value
                resetAnimation(
                    duration: duration,
                    delay: delay,
                    autoreverses: autoreverses,
                    proxy: proxy
                )
            })
            .onAppear {
                self.isAppear = true
                resetAnimation(
                    duration: duration,
                    delay: delay,
                    autoreverses: autoreverses,
                    proxy: proxy
                )
            }
            .onDisappear {
                self.isAppear = false
            }
            .onChange(of: duration) { [] newDuration in
                resetAnimation(
                    duration: newDuration,
                    delay: delay,
                    autoreverses: autoreverses,
                    proxy: proxy
                )
            }
            .onChange(of: delay) { [] newDelay in
                resetAnimation(
                    duration: duration,
                    delay: newDelay,
                    autoreverses: autoreverses,
                    proxy: proxy
                )
            }
            .onChange(of: autoreverses) { [] newAutoreverses in
                resetAnimation(
                    duration: duration,
                    delay: delay,
                    autoreverses: newAutoreverses,
                    proxy: proxy
                )
            }
            .onChange(of: direction) { [] _ in
                resetAnimation(
                    duration: duration,
                    delay: delay,
                    autoreverses: autoreverses,
                    proxy: proxy
                )
            }
        }.clipped()
    }
    
    private func offsetX(proxy: GeometryProxy) -> CGFloat {
        switch self.state {
        case .idle:
            switch idleAlignment {
            case .center:
                return 0.5*(proxy.size.width-contentWidth)
            case .trailing:
                return proxy.size.width-contentWidth
            default:
                return 0
            }
        case .ready:
            return (direction == .right2left)
                            ? boundary == .outer ? proxy.size.width : 0
                            : -contentWidth
        case .animating:
            return (direction == .right2left)
                            ? boundary == .outer ? -contentWidth : proxy.size.width - contentWidth
                            : proxy.size.width
        }
    }
    
    private func resetAnimation(duration: Double, delay: Double, autoreverses: Bool, proxy: GeometryProxy) {
        if duration == 0 || duration == Double.infinity {
            stopAnimation()
        } else {
            startAnimation(duration: duration, delay: delay, autoreverses: autoreverses, proxy: proxy)
        }
    }
    
    private func startAnimation(duration: Double, delay: Double, autoreverses: Bool, proxy: GeometryProxy) {
        let isNotFit = contentWidth < proxy.size.width
        if stopWhenNotFit && isNotFit {
            stopAnimation()
            return
        }
        
        withAnimation(.instant) {
            self.state = .ready
            let animation = Animation
                .linear(duration: duration)
                .delay(delay)
                .repeatForever(autoreverses: autoreverses)
            withAnimation(animation) {
                self.state = .animating
            }
        }
    }
    
    private func stopAnimation() {
        withAnimation(.instant) {
            self.state = .idle
        }
    }
}

struct Marquee_Previews: PreviewProvider {
    static var previews: some View {
        Marquee {
            Text("Hello World!")
                .fontWeight(.bold)
                .font(.system(size: 40))
        }
        .marqueeDelay(0.5)
    }
}
