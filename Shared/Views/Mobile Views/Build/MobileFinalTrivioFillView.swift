//
//  MobileFinalTrivioFillView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioFillView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text(buildVM.stepStringHandler())
                .font(formatter.font(fontSize: .mediumLarge))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: 15) {
                    MobileCategoryLargeView(categoryName: buildVM.fjCategory)
                    VStack (alignment: .leading, spacing: 3) {
                        Text("CATEGORY")
                            .font(formatter.font(fontSize: .mediumLarge))
                        MobileCategoryNameTextFieldView(categoryName: $buildVM.fjCategory)
                    }
                    
                    VStack (alignment: .leading, spacing: 3) {
                        Text("CLUE")
                            .font(formatter.font(fontSize: .mediumLarge))
                        MobileMultilineTextField("ENTER A CLUE", text: $buildVM.fjClue) {
                            
                        }
                        .accentColor(formatter.color(.secondaryAccent))
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(5)
                    }
                    
                    VStack (alignment: .leading, spacing: 3) {
                        Text("CORRECT RESPONSE")
                            .font(formatter.font(fontSize: .mediumLarge))
                            .foregroundColor(formatter.color(.secondaryAccent))
                        MobileMultilineTextField("ENTER A RESPONSE", text: $buildVM.fjResponse) {
                            
                        }
                        .accentColor(formatter.color(.secondaryAccent))
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(5)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(formatter.color(.primaryAccent))
            .cornerRadius(20)
        }
    }
}

