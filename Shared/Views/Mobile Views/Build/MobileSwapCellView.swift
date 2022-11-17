//
//  MobileSwapCellView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileSwapCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var category: CustomSetCategory
    @Binding var preSwapIndex: Int
    
    @State var clueIndex: Int
    @State var currentHeldIndex = -1
    
    var clue: String {
        return category.clues[clueIndex]
    }
    
    var response: String {
        return category.responses[clueIndex]
    }
    
    var amount: String {
        return buildVM.moneySections[clueIndex]
    }
    
    var body: some View {
        Text(amount)
            .font(formatter.font(fontSize: .mediumLarge))
            .foregroundColor(formatter.color(.secondaryAccent).opacity((clue.isEmpty || response.isEmpty) ? 0.5 : 1))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(formatter.color(buildVM.editingClueIndex == clueIndex ? .secondaryFG : .primaryFG))
            .cornerRadius(5)
            .padding(1.5)
            .background(RoundedRectangle(cornerRadius: 5).stroke(formatter.color(.highContrastWhite), lineWidth: preSwapIndex == clueIndex ? 2 : 0))
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                formatter.resignKeyboard()
                if preSwapIndex == clueIndex {
                    preSwapIndex = -1
                } else if clueIndex != buildVM.editingClueIndex {
                    preSwapIndex = clueIndex
                }
            }
    }
}

