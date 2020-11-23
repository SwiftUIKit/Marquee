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

private enum MarqueeState {
    case idle
    case ready
    case animating
}

public struct Marquee<Content> : View where Content : View {
    @Environment(\.marqueeDuration) var duration
    @Environment(\.marqueeAutoreverses) var autoreverses: Bool
    @Environment(\.marqueeDirection) var direction: MarqueeDirection
    
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
                Spacer()
                if isAppear {
                    content()
                        .background(GeometryBackground())
                        .fixedSize(horizontal: true, vertical: false)
                        .myOffset(x: offsetX(proxy: proxy), y: 0)
                } else {
                    Text("")
                }
                Spacer()
            }
            // Listen content width changes
            .onPreferenceChange(WidthKey.self, perform: { value in
                self.contentWidth = value
                resetAnimation(duration: duration, autoreverses: autoreverses)
            })
            .onAppear {
                self.isAppear = true
                resetAnimation(duration: duration, autoreverses: autoreverses)
            }
            .onDisappear {
                self.isAppear = false
            }
            .onChange(of: duration) { [] newDuration in
                resetAnimation(duration: newDuration, autoreverses: self.autoreverses)
            }
            .onChange(of: autoreverses) { [] newAutoreverses in
                resetAnimation(duration: self.duration, autoreverses: newAutoreverses)
            }
            .onChange(of: direction) { [] _ in
                resetAnimation(duration: duration, autoreverses: autoreverses)
            }
        }.clipped()
    }
    
    private func offsetX(proxy: GeometryProxy) -> CGFloat {
        switch self.state {
        case .idle:
            return 0
        case .ready:
            return (direction == .right2left) ? proxy.size.width : -contentWidth
        case .animating:
            return (direction == .right2left) ? -contentWidth : proxy.size.width
        }
    }
    
    private func resetAnimation(duration: Double, autoreverses: Bool) {
        if duration == 0 || duration == Double.infinity {
            stopAnimation()
        } else {
            startAnimation(duration: duration, autoreverses: autoreverses)
        }
    }
    
    private func startAnimation(duration: Double, autoreverses: Bool) {
        withAnimation(.instant) {
            self.state = .ready
            withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: autoreverses)) {
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
    }
}
