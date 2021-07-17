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
        case .small:
            sizeFloat = deviceType == .iPhone ? 12 : 14
        case .regular:
            sizeFloat = deviceType == .iPhone ? 14 : 16
        case .medium:
            sizeFloat = deviceType == .iPhone ? 16 : 20
        case .mediumLarge:
            sizeFloat = deviceType == .iPhone ? 18 : 25
        case .large:
            sizeFloat = deviceType == .iPhone ? 22 : 35
        case .extraLarge:
            sizeFloat = deviceType == .iPhone ? 30 : 45
        }
        
        return Font.custom("Metropolis-" + styleString, size: sizeFloat)
    }
}

enum FontStyle {
    case regular, regularItalic, medium, bold, boldItalic, extraBold
}

enum FontSize {
    case small, regular, medium, mediumLarge, large, extraLarge
}
