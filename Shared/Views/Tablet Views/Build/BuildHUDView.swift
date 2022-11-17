//
//  BuildHUDView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct BuildHUDView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack (spacing: 25) {
                if buildVM.buildStage != .trivioRound {
                    Button {
                        self.buildVM.back()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .bold))
                            Text(buildVM.backStringHandler())
                        }
                    }
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 30)
                        .foregroundColor(formatter.color(.lowContrastWhite))
                }
                Text(buildVM.descriptionHandler())
                    .foregroundColor(formatter.color(.secondaryAccent))
                
                if buildVM.buildStage == .trivioRoundDD || buildVM.buildStage == .dtRoundDD {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 30)
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    DuplexOfTheDaySelectionMethodView()
                } else if buildVM.buildStage == .trivioRound || buildVM.buildStage == .dtRound {
                    if buildVM.currentDisplay == .grid {
                        RoundedRectangle(cornerRadius: 2)
                            .frame(width: 1, height: 30)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                        CategoryCountIncrementView()
                    }
                }
            }
            .font(formatter.font(fontSize: .mediumLarge))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(formatter.color(.primaryFG))
        .cornerRadius(5)
    }
}

struct CategoryCountIncrementView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        HStack (spacing: 15) {
            Text("Categories: ")
            
            HStack (spacing: 7) {
                Button(action: {
                    buildVM.subtractCategory()
                }, label: {
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .bold))
                        .padding(15)
                })
                Text("\(buildVM.buildStage == .trivioRound ? buildVM.jRoundLen : buildVM.djRoundLen)")
                    .font(formatter.font())
                Button(action: {
                    buildVM.addCategory()
                }, label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .padding(15)
                })
            }
            .padding(.horizontal, 5)
            .background(formatter.color(.secondaryFG))
            .clipShape(Capsule())
        }
    }
}

struct DuplexOfTheDaySelectionMethodView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        HStack (spacing: 10) {
            Text("Selection:")
            Text("Random")
                .padding(10)
                .background(formatter.color(buildVM.isRandomDD ? .primaryAccent : .primaryFG))
                .cornerRadius(5)
                .onTapGesture {
                    if !self.buildVM.isRandomDD {
                        self.buildVM.randomDDs()
                    }
                    self.buildVM.isRandomDD = true
                }
            Text("Manual")
                .padding(10)
                .background(formatter.color(buildVM.isRandomDD ? .primaryFG : .primaryAccent))
                .cornerRadius(5)
                .onTapGesture {
                    if self.buildVM.isRandomDD {
                        self.buildVM.clearDailyDoubles()
                    }
                    self.buildVM.isRandomDD = false
                }
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(formatter.color(buildVM.ddsFilled() ? .highContrastWhite : .lowContrastWhite))
        }
        .font(formatter.font())
    }
}
