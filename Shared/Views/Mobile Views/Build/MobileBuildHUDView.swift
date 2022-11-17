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
    
    let buildStageIndexDict = MobileBuildStageIndexDict()
    
    var mostAdvancedStageIndex: Int {
        return buildStageIndexDict.getIndex(from: buildVM.mostAdvancedStage)
    }
    
    func getBuildStageIndex(_ buildStage: BuildStage) -> Int {
        return buildStageIndexDict.getIndex(from: buildStage)
    }
    
    var body: some View {
        HStack (spacing: 3) {
            Image(systemName: "gear")
                .foregroundColor(formatter.color(.primaryBG))
                .font(formatter.iconFont(.medium))
                .frame(width: 50, height: 50)
                .background(formatter.color(.highContrastWhite))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .details ? 2 : 0)
                )
                .onTapGesture {
                    formatter.hapticFeedback(style: .rigid)
                    buildVM.buildStage = .details
                    buildVM.currentDisplay = .settings
                }
            Text("Round 1")
                .font(formatter.font(fontSize: .small))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .trivioRound ? 2 : 0)
                )
                .opacity(getBuildStageIndex(.trivioRound) <= mostAdvancedStageIndex ? 1 : 0.4)
                .onTapGesture {
                    if getBuildStageIndex(.trivioRound) <= mostAdvancedStageIndex {
                        formatter.hapticFeedback(style: .rigid)
                        buildVM.changePointValues(isAdvancing: false)
                        buildVM.buildStage = .trivioRound
                        buildVM.currentDisplay = .grid
                    }
                }
            Rectangle()
                .fill(formatter.color(.primaryAccent))
                .frame(width: 7, height: 50)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .trivioRoundDD ? 2 : 0)
                )
                .opacity(getBuildStageIndex(.trivioRoundDD) <= mostAdvancedStageIndex ? 1 : 0.4)
                .onTapGesture {
                    if getBuildStageIndex(.trivioRoundDD) <= mostAdvancedStageIndex {
                        formatter.hapticFeedback(style: .rigid)
                        buildVM.changePointValues(isAdvancing: false)
                        buildVM.buildStage = .trivioRoundDD
                        buildVM.currentDisplay = .grid
                    }
                }
            if buildVM.currCustomSet.hasTwoRounds {
                Text("Round 2")
                    .font(formatter.font(fontSize: .small))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(formatter.color(.secondaryFG))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .dtRound ? 2 : 0)
                    )
                    .opacity(getBuildStageIndex(.dtRound) <= mostAdvancedStageIndex ? 1 : 0.4)
                    .onTapGesture {
                        if getBuildStageIndex(.dtRound) <= mostAdvancedStageIndex {
                            formatter.hapticFeedback(style: .rigid)
                            buildVM.changePointValues(isAdvancing: true)
                            buildVM.buildStage = .dtRound
                            buildVM.currentDisplay = .grid
                        }
                    }
                Rectangle()
                    .fill(formatter.color(.primaryAccent))
                    .frame(width: 7, height: 50)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .dtRoundDD ? 2 : 0)
                    )
                    .opacity(getBuildStageIndex(.dtRoundDD) <= mostAdvancedStageIndex ? 1 : 0.4)
                    .onTapGesture {
                        if getBuildStageIndex(.dtRoundDD) <= mostAdvancedStageIndex {
                            formatter.hapticFeedback(style: .rigid)
                            buildVM.changePointValues(isAdvancing: true)
                            buildVM.buildStage = .dtRoundDD
                            buildVM.currentDisplay = .grid
                        }
                    }
            }
            Text("Final Round")
                .font(formatter.font(fontSize: .small))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(formatter.color(.secondaryAccent), lineWidth: buildVM.buildStage == .finalTrivio ? 2 : 0)
                )
                .opacity(getBuildStageIndex(.finalTrivio) <= mostAdvancedStageIndex ? 1 : 0.4)
                .onTapGesture {
                    if getBuildStageIndex(.finalTrivio) <= mostAdvancedStageIndex {
                        buildVM.buildStage = .finalTrivio
                        buildVM.currentDisplay = .finalTrivio
                    }
                }
        }
        .padding([.top, .horizontal])
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
