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
        // this is stupid i should be using raw values wtf
        var colorString = ""
        switch colorType {
        case .black: return Color.black
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

struct ColorMap {
    let formatter = MasterHandler()
    
    func getColor(color: String) -> Color {
        switch color {
        case "orange":
            return formatter.color(.orange)
        case "yellow":
            return formatter.color(.yellow)
        case "purple":
            return formatter.color(.purple)
        case "red":
            return formatter.color(.red)
        case "pink":
            return Color.pink
        case "green":
            return formatter.color(.green)
        default:
            return formatter.color(.blue)
        }
    }
}

enum ColorType {
    case blue, green, highContrastWhite, lowContrastWhite, mediumContrastWhite, orange, primaryAccent, primaryBG, primaryFG, purple, red, secondaryAccent, secondaryFG, yellow, black
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

