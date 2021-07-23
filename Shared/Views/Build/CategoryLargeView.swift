//
//  CategoryLargeView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct CategoryLargeView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var categoryName: String
    var width: CGFloat = 300
    
    var body: some View {
        Text(categoryName.uppercased())
            .font(formatter.font())
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.1)
            .padding(10)
            .frame(width: width, height: 150)
            .background(formatter.color(.lowContrastWhite))
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
