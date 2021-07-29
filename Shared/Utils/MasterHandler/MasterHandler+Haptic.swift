//
//  MasterHandler+Haptic.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import UIKit

// MARK: - Haptic Feedback
extension MasterHandler {
    /*
     Haptic rulebook:
     Entering into a new Navigation View: light
     Tapping a responsive view: medium
     Selecting a menu choice: rigid, weak
     Tapping a button: soft, strong intensity
     Alert: rigid
     */
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: HapticIntensity = .normal) {
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity.rawValue)
    }
}

enum HapticIntensity: CGFloat {
    case strong = 100
    case normal = 1
    case weak = 0.5
}
