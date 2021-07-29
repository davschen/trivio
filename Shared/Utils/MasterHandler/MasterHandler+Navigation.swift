//
//  MasterHandler+Navigation.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

extension MasterHandler {
    func buttonBack(dismiss: @escaping () -> ()) -> some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .heavy))
                Text("Back")
                    .font(font())
            }
            .foregroundColor(color(.highContrastWhite))
        }
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
