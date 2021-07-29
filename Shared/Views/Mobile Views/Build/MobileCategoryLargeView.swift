//
//  MobileCategoryLargeView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileCategoryLargeView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var categoryName: String
    var width: CGFloat = 300
    
    var body: some View {
        Text(categoryName.uppercased())
            .font(formatter.font())
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.1)
            .padding(10)
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(formatter.color(.lowContrastWhite))
            .cornerRadius(5)
    }
}

