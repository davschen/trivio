//
//  MobileBuildCategoryView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileBuildCategoryView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var categoryIndex: Int
    @Binding var category: Category
    
    @State var index: Int
    @State var isHeld = -1
    
    var body: some View {
        VStack (spacing: 7) {
            Text(self.category.name.isEmpty ? "ADD NAME" : self.category.name.uppercased())
                .font(formatter.font(category.name.isEmpty ? .boldItalic : .bold))
                .foregroundColor(formatter.color(category.name.isEmpty ? .lowContrastWhite : .highContrastWhite))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, 5)
                .frame(width: 150, height: 90)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(10)
                .onTapGesture {
                    if buildVM.buildStage == .trivioRoundDD || buildVM.buildStage == .dtRoundDD {
                        return
                    }
                    
                    buildVM.currentDisplay = .categoryName
                    buildVM.editingCategoryIndex = index
                    
                    if buildVM.buildStage == .dtRound {
                        buildVM.djCategories[index].setIndex(index: index)
                    } else {
                        buildVM.jCategories[index].setIndex(index: index)
                    }
                    
                    categoryIndex = index
                }
            VStack (spacing: 5) {
                ForEach(0..<category.clues.count) { i in
                    let amount = buildVM.moneySections[i]
                    let clue = category.clues[i]
                    let response = category.responses[i]
                    MobileBuildCellView(isHeld: $isHeld, categoryIndex: $categoryIndex, category: $category, index: $index, i: i, amount: amount, clue: clue, response: response)
                }
            }
        }
    }
}

