//
//  MobileBuildHUDView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileBuildHUDView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var shouldDisplayProgressChrevrons: Bool {
        return buildVM.currentDisplay != .categoryName
            && buildVM.currentDisplay != .clueResponse
            && buildVM.currentDisplay != .saveDraft
    }
    
    var body: some View {
        HStack (spacing: 15) {
            Button {
                if buildVM.buildStage != .trivioRound {
                    formatter.hapticFeedback(style: .light, intensity: .strong)
                    buildVM.back()
                }
            } label: {
                Image(systemName: "chevron.left.square.fill")
                    .font(formatter.iconFont())
                    .foregroundColor(formatter.color(buildVM.buildStage == .trivioRound ? .lowContrastWhite : .highContrastWhite))
            }
            .opacity(shouldDisplayProgressChrevrons ? 1 : 0)
            VStack (spacing: 5) {                
                Text(buildVM.descriptionHandler())
                    .foregroundColor(formatter.color(.secondaryAccent))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                
                if buildVM.buildStage == .trivioRoundDD || buildVM.buildStage == .dtRoundDD {
                    MobileDuplexSelectionMethodView()
                } else if buildVM.buildStage == .trivioRound || buildVM.buildStage == .dtRound {
                    if buildVM.currentDisplay == .grid {
                        MobileCategoryCountIncrementView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            Button {
                if buildVM.nextPermitted() {
                    formatter.hapticFeedback(style: .light, intensity: .strong)
                    buildVM.nextButtonHandler()
                }
            } label: {
                Image(systemName: "chevron.right.square.fill")
                    .font(formatter.iconFont())
                    .foregroundColor(formatter.color(buildVM.nextPermitted() ? .highContrastWhite : .lowContrastWhite))
            }
            .opacity(shouldDisplayProgressChrevrons ? 1 : 0)
        }
        .font(formatter.font())
        .padding(10)
        .frame(height: 80)
        .background(formatter.color(.primaryFG))
        .cornerRadius(5)
    }
}

struct MobileCategoryCountIncrementView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        HStack (spacing: 15) {
            Text("Categories: ")
                .lineLimit(1)
            
            HStack (spacing: 5) {
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    buildVM.subtractCategory(index: 0, last: true)
                }, label: {
                    Image(systemName: "minus")
                        .font(formatter.iconFont(.small))
                        .padding(7)
                })
                Text("\(buildVM.buildStage == .trivioRound ? buildVM.jRoundLen : buildVM.djRoundLen)")
                    .font(formatter.font(fontSize: .regular))
                    .frame(width: 15)
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    buildVM.addCategory()
                }, label: {
                    Image(systemName: "plus")
                        .font(formatter.iconFont(.small))
                        .padding(7)
                })
            }
            .padding(.horizontal, 5)
            .background(formatter.color(.secondaryFG))
            .clipShape(Capsule())
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct MobileDuplexSelectionMethodView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        HStack (spacing: 5) {
            Text("Random")
                .padding(5)
                .padding(.horizontal, 5)
                .background(formatter.color(buildVM.isRandomDD ? .primaryAccent : .primaryFG))
                .cornerRadius(3)
                .onTapGesture {
                    formatter.hapticFeedback(style: .rigid, intensity: .weak)
                    if !buildVM.isRandomDD {
                        buildVM.randomDDs()
                    }
                    buildVM.isRandomDD = true
                }
            Text("Manual")
                .padding(5)
                .padding(.horizontal, 5)
                .background(formatter.color(buildVM.isRandomDD ? .primaryFG : .primaryAccent))
                .cornerRadius(3)
                .onTapGesture {
                    formatter.hapticFeedback(style: .rigid, intensity: .weak)
                    if buildVM.isRandomDD {
                        buildVM.clearDailyDoubles()
                    }
                    buildVM.isRandomDD = false
                }
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(formatter.color(buildVM.ddsFilled() ? .highContrastWhite : .lowContrastWhite))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
