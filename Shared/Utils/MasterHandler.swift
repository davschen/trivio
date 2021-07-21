//
//  MasterHandler.swift
//  Trivio!
//
//  Created by David Chen on 5/24/21.
//

import Foundation
import SwiftUI
import Network

class MasterHandler: ObservableObject {
    @Published var showingAlert = false
    @Published var showingTabBar = true
    @Published var volume: Float = 1
    @Published var speaker = Speaker()
    
    @Namespace var namespace
    
    var alertStyle: AlertStyle = .standard
    var alertAction: () -> () = { print("default alert") }
    var alertTitle = ""
    var alertSubtitle = ""
    var hasCancel = true
    var actionLabel = ""
    var hasSecondaryAction = false
    var secondaryAction: () -> () = { print("secondary alert") }
    var secondaryActionLabel = ""
    
    var deviceType: DeviceType {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        default:
            return .iPad
        }
    }
    
    func setAlertSettings(alertAction: @escaping () -> () = { return },
                          alertTitle: String = "",
                          alertSubtitle: String = "",
                          hasCancel: Bool = true,
                          actionLabel: String = "",
                          hasSecondaryAction: Bool = false,
                          secondaryAction: @escaping () -> () = { return },
                          secondaryActionLabel: String = "") {
        self.alertStyle = .loading
        self.alertAction = alertAction
        self.alertTitle = alertTitle
        self.alertSubtitle = alertSubtitle
        self.hasCancel = hasCancel
        self.actionLabel = actionLabel
        self.hasSecondaryAction = hasSecondaryAction
        self.secondaryAction = secondaryAction
        self.secondaryActionLabel = secondaryActionLabel
        self.showingAlert = true
    }
    
    func setLoadingSettings(alertSubtitle: String) {
        self.alertStyle = .loading
        self.alertSubtitle = alertSubtitle
        self.showingAlert = true
    }
    
    func dismissAlert() {
        self.showingAlert = false
    }
    
    func padding(size: CGFloat = 15) -> CGFloat {
        if deviceType == .iPhone {
            if size == 15 {
                return 10
            } else if size > 15 {
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
        if deviceType == .iPad { return iPadSize }
        if iPadSize < 5 {
            return iPadSize
        } else if iPadSize == 5 {
            return 3
        } else {
            return CGFloat(Int(iPadSize * 0.5))
        }
    }
    
    func shrink(iPadSize: CGFloat, factor: Double = 2) -> CGFloat {
        if deviceType == .iPad { return iPadSize }
        return CGFloat(Int(iPadSize / CGFloat(factor)))
    }
    
    func cornerRadius(_ iPadSize: CGFloat) -> CGFloat {
        return deviceType == .iPad ? iPadSize : CGFloat(Int(iPadSize / 2))
    }
    
    func resignKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // putting the implementation of this on hold for a bit
    func detectNetworkConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if !(path.status == .satisfied) {
                self.setLoadingSettings(alertSubtitle: "No Internet Connection Detected")
            } else {
                self.dismissAlert()
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func setVolume() {
        speaker.updateVolume(value: volume)
    }
}

