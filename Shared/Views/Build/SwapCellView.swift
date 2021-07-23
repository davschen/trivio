//
//  SwapBlockView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct SwapCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @Binding var editingIndex: Int
    @Binding var preSwapIndex: Int
    
    @State var currentHeldIndex = -1
    @State var clueIndex: Int
    
    var amount: String
    var clue: String
    var response: String
    
    var body: some View {
        ZStack {
            if currentHeldIndex == clueIndex {
                if !clue.isEmpty || !response.isEmpty {
                    BuildCellHeldView()
                } else {
                    Text("EMPTY TILE")
                        .font(formatter.font(.boldItalic))
                        .foregroundColor(.white.opacity(0.75))
                }
            } else {
                Text("$\(amount)")
                    .font(formatter.font(.extraBold, fontSize: .large))
                    .foregroundColor(formatter.color(.secondaryAccent).opacity((clue.isEmpty || response.isEmpty) ? 0.5 : 1))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).stroke(formatter.color(.highContrastWhite), lineWidth: preSwapIndex == clueIndex ? 10 : 0))
        .background(formatter.color(editingIndex == clueIndex ? .secondaryFG : .lowContrastWhite))
        .cornerRadius(10)
        .onTapGesture {
            formatter.resignKeyboard()
            if preSwapIndex == clueIndex {
                preSwapIndex = -1
            } else if clueIndex != editingIndex {
                preSwapIndex = clueIndex
            }
        }
        .onLongPressGesture(minimumDuration: 1, pressing: { inProgress in
            buildVM.setPreviews(clue: clue, response: response)
            currentHeldIndex = inProgress ? clueIndex : -1
        }) {
            currentHeldIndex = -1
        }
    }
}
