//
//  FinalTrivioFillView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct FinalTrivioFillView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    CategoryLargeView(categoryName: buildVM.fjCategory)
                    Text("CATEGORY")
                        .font(formatter.font(fontSize: .large))
                    CategoryNameTextFieldView(categoryName: $buildVM.fjCategory)
                    
                    Text("CLUE")
                        .font(formatter.font(fontSize: .large))
                    MultilineTextField("ENTER A CLUE", text: $buildVM.fjClue) {
                        
                    }
                    .accentColor(formatter.color(.secondaryAccent))
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(10)
                    
                    Text("CORRECT RESPONSE")
                        .font(formatter.font(fontSize: .large))
                        .foregroundColor(formatter.color(.secondaryAccent))
                    MultilineTextField("ENTER A RESPONSE", text: $buildVM.fjResponse) {
                        
                    }
                    .accentColor(formatter.color(.secondaryAccent))
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(10)
                }
                .padding(30)
            }
            .keyboardAware()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(30)
    }
}
