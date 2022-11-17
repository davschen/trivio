//
//  BuildCellView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct BuildCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var isHeld: Int
    @Binding var categoryIndex: Int
    @Binding var category: CustomSetCategory
    @Binding var index: Int
    
    var i: Int
    var amount: String
    var clue: String
    var response: String
    
    var isDJ: Bool {
        return buildVM.buildStage == .dtRound || buildVM.buildStage == .dtRoundDD
    }
    
    var body: some View {
        ZStack {
            if isHeld == i {
                BuildCellHeldView()
            } else {
                ZStack {
                    Text("$\(amount)")
                        .font(formatter.font(.extraBold, fontSize: .large))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(formatter.color(.secondaryAccent).opacity((clue.isEmpty || response.isEmpty) ? 0.5 : 1))
                        .multilineTextAlignment(.center)
                    if (buildVM.buildStage == .trivioRound) || (buildVM.buildStage == .dtRound) {
                        Image(systemName: (clue.isEmpty || response.isEmpty) ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .opacity(category.name.isEmpty ? 0 : 0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(5)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).stroke(
            (buildVM.buildStage == .trivioRound || buildVM.buildStage == .dtRound) ? formatter.color(.primaryAccent) : formatter.color(.highContrastWhite),
            lineWidth: self.buildVM.isDailyDouble(i: category.index, j: i) ? 10 : 0
        ))
        .background(formatter.color((clue.isEmpty || response.isEmpty) ? .primaryFG : .primaryAccent))
        .cornerRadius(10)
        .onTapGesture {
            if (buildVM.buildStage == .trivioRoundDD
                || buildVM.buildStage == .dtRoundDD)
                && (!category.clues[i].isEmpty && !category.responses[i].isEmpty) {
                buildVM.addDailyDouble(i: category.index, j: i)
            } else if !category.name.isEmpty {
                buildVM.currentDisplay = .buildAll
                buildVM.setEditingIndex(index: i)
                categoryIndex = index
            }
        }
        .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
            if (!clue.isEmpty || !response.isEmpty) {
                buildVM.setPreviews(clue: clue, response: response)
                isHeld = inProgress ? i : -1
            }
        }) {
            isHeld = -1
        }
    }
}

struct BuildCellHeldView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Text(buildVM.cluePreview)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(buildVM.responsePreview)
                .foregroundColor(formatter.color(.secondaryAccent))
                .lineLimit(1)
        }
        .padding()
        .font(formatter.font(fontSize: .small))
    }
}
