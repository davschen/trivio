//
//  BuildCategoryView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct BuildCategoryView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @Binding var categoryIndex: Int
    @Binding var category: CustomSetCategory
    @State var index: Int
    @State var isHeld = -1
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: 7) {
            Text(self.category.name.isEmpty ? "ADD NAME" : self.category.name.uppercased())
                .font(formatter.font(category.name.isEmpty ? .boldItalic : .bold))
                .foregroundColor(formatter.color(category.name.isEmpty ? .lowContrastWhite : .highContrastWhite))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(10)
                .onTapGesture {
                    if buildVM.buildStage == .trivioRoundDD || buildVM.buildStage == .dtRoundDD {
                        return
                    }
                    
                    buildVM.currentDisplay = .buildAll
                    
                    if buildVM.buildStage == .dtRound {
                        buildVM.djCategories[index].setIndex(index: index)
                    } else {
                        buildVM.jCategories[index].setIndex(index: index)
                    }
                    
                    categoryIndex = index
                }
            VStack (spacing: 7) {
                ForEach(0..<category.clues.count) { i in
                    let amount = buildVM.moneySections[i]
                    let clue = category.clues[i]
                    let response = category.responses[i]
                    BuildCellView(isHeld: $isHeld, categoryIndex: $categoryIndex, category: $category, index: $index, i: i, amount: amount, clue: clue, response: response)
                }
            }
        }
    }
}
