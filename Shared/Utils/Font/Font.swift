//
//  Font.swift
//  Trivio!
//
//  Created by David Chen on 7/7/21.
//

import Foundation
import SwiftUI

extension MasterHandler {
    func font(_ fontStyle: FontStyle = .bold, fontSize: FontSize = .medium) -> Font {
        var styleString = ""
        var sizeFloat: CGFloat = 15
        
        switch fontStyle {
        case .regular: styleString = "Regular"
        case .regularItalic: styleString = "RegularItalic"
        case .medium: styleString = "Medium"
        case .boldItalic: styleString = "ExtraBoldItalic"
        case .extraBold: styleString = "ExtraBold"
        default: styleString = "Bold"
        }
        
        switch fontSize {
        case .micro:
            sizeFloat = deviceType == .iPhone ? 8 : 10
        case .small:
            sizeFloat = deviceType == .iPhone ? 12 : 14
        case .regular:
            sizeFloat = deviceType == .iPhone ? 14 : 16
        case .medium:
            sizeFloat = deviceType == .iPhone ? 16 : 20
        case .mediumLarge:
            sizeFloat = deviceType == .iPhone ? 20 : 25
        case .semiLarge:
            sizeFloat = deviceType == .iPhone ? 25 : 30
        case .large:
            sizeFloat = deviceType == .iPhone ? 30 : 35
        case .extraLarge:
            sizeFloat = deviceType == .iPhone ? 35 : 45
        }
        
        return Font.custom("Metropolis-" + styleString, size: sizeFloat)
    }
    
    func iconFont(_ systemFontSize: SystemFontSize = .medium) -> Font {
        return .system(size: systemFontSize.rawValue, weight: .bold)
    }
}

enum FontStyle {
    case regular, regularItalic, medium, bold, boldItalic, extraBold
}

enum FontSize {
    case micro, small, regular, medium, mediumLarge, semiLarge, large, extraLarge
}

enum SystemFontSize: CGFloat {
    case small = 15
    case medium = 20
    case mediumLarge = 25
    case large = 30
}
