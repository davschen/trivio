//
//  Color.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/7/21.
//

import Foundation
import SwiftUI

extension MasterHandler {
    func color(_ colorType: ColorType) -> Color {
        var colorString = ""
        switch colorType {
        case .blue: colorString = "Blue"
        case .green: colorString = "Green"
        case .highContrastWhite: colorString = "High Contrast White"
        case .lowContrastWhite: colorString = "Low Contrast White"
        case .mediumContrastWhite: colorString = "Medium Contrast White"
        case .orange: colorString = "Orange"
        case .primaryAccent: colorString = "Primary Accent"
        case .primaryBG: colorString = "Primary BG"
        case .purple: colorString = "Purple"
        case .red: colorString = "Red"
        case .secondaryAccent: colorString = "Secondary Accent"
        case .secondaryFG: colorString = "Secondary FG"
        case .yellow: colorString = "Yellow"
        default: colorString = "Primary FG"
        }
        return Color(colorString)
    }
}

enum ColorType {
    case blue, green, highContrastWhite, lowContrastWhite, mediumContrastWhite, orange, primaryAccent, primaryBG, primaryFG, purple, red, secondaryAccent, secondaryFG, yellow
}
