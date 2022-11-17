//
//  MobileBuildFooterView.swift
//  Trivio!
//
//  Created by David Chen on 10/28/22.
//

import Foundation
import SwiftUI

struct MobileBuildFooterView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        HStack {
            if buildVM.buildStage != .details {
                Button {
                    buildVM.back()
                } label: {
                    Text("Back")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(formatter.color(.highContrastWhite))
                        .clipShape(Capsule())
                }
            }
            
            Button {
                if buildVM.nextPermitted() {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    if buildVM.buildStage == .finalTrivio {
                        gamesVM.readCustomData()
                    }
                    buildVM.nextButtonHandler()
                }
            } label: {
                if buildVM.buildStage != .finalTrivio {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(formatter.color(buildVM.buildStage == .finalTrivio ? .secondaryAccent : .highContrastWhite))
                } else {
                    HStack {
                        Text("Publish")
                        Image(systemName: "wand.and.stars")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(formatter.color(buildVM.buildStage == .finalTrivio ? .secondaryAccent : .highContrastWhite))
                }
            }
            .clipShape(Capsule())
            .opacity(buildVM.nextPermitted() ? 1 : 0.4)
        }
        .foregroundColor(formatter.color(.primaryBG))
        .padding([.bottom])
        .padding(.bottom, 15)
    }
}
