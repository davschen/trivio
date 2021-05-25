//
//  MasterHandler.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import SwiftUI

class MasterHandler: ObservableObject {
    var deviceType: DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        default:
            return .iPad
        }
    }
    
    func padding(size: CGFloat = 15) -> CGFloat {
        if deviceType == .iPhone {
            if size > 15 {
                return CGFloat(Int(size * 0.66))
            }
        }
        return size
    }
    
    private func calculateFontSize(iPadSize: CGFloat) -> CGFloat {
        if iPadSize <= 14 {
            return iPadSize
        } else if iPadSize <= 20 {
            return CGFloat(Int(iPadSize * 0.75))
        } else {
            return CGFloat(Int(iPadSize * 0.5))
        }
    }
    
    func customFont(weight: String = "", iPadSize: CGFloat) -> Font {
        var size = iPadSize
        if deviceType == .iPhone {
            size = calculateFontSize(iPadSize: iPadSize)
        }
        return Font.custom("Avenir Next\(weight.isEmpty ? "" : " \(weight)")", size: size)
    }
    
    func cornerRadius(iPadSize: CGFloat) -> CGFloat {
        if iPadSize < 5 {
            return iPadSize
        } else {
            return CGFloat(Int(iPadSize * 0.5))
        }
    }
    
    func shrink(iPadSize: CGFloat, factor: Double = 2) -> CGFloat {
        return CGFloat(Int(iPadSize / CGFloat(factor)))
    }
}
