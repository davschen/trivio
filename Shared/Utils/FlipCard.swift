//
//  FlipCard.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/26/23.
//

import Foundation
import SwiftUI

struct FlipCard<FrontView: View, BackView: View>: View {
    @Binding var flipped: Bool

    var frontView: FrontView
    var backView: BackView

    init(flipped: Binding<Bool>, @ViewBuilder front: () -> FrontView, @ViewBuilder back: () -> BackView) {
        self._flipped = flipped
        self.frontView = front()
        self.backView = back()
    }

    var body: some View {
        ZStack() {
            frontView.opacity(flipped ? 0.0 : 1.0)
            backView.opacity(flipped ? 1.0 : 0.0)
        }
        .modifier(FlipEffect(flipped: $flipped, angle: flipped ? 180 : 0, axis: (x: 1, y: 0)))
    }
}

struct FlipEffect: GeometryEffect {
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    @Binding var flipped: Bool
    var angle: Double
    let axis: (x: CGFloat, y: CGFloat)

    func effectValue(size: CGSize) -> ProjectionTransform {
        
        DispatchQueue.main.async {
            self.flipped = self.angle >= 90 && self.angle < 270
        }
        
        let tweakedAngle = flipped ? -180 + angle : angle
        let a = CGFloat(Angle(degrees: tweakedAngle).radians)
        
        var transform3d = CATransform3DIdentity;
        transform3d.m34 = -1/max(size.width, size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
}
