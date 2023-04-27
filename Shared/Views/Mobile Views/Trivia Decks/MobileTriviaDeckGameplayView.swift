//
//  TriviaDeckGameplayView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/22/23.
//

import Foundation
import SwiftUI

struct MobileTriviaDeckGameplayView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel

    @State var doneWritingTriviaDeckClue = false
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            switch exploreVM.triviaDeckClueViewState.triviaDeckDisplayMode {
            case .dailyChallengeClue:
                HStack {}
            case .buildingCustomClue:
                if doneWritingTriviaDeckClue {
                    MobileTriviaDeckSubmittedClueView(doneWritingTriviaDeckClue: $doneWritingTriviaDeckClue)
                } else {
                    MobileTriviaDeckSubmitClueView(doneWritingTriviaDeckClue: $doneWritingTriviaDeckClue)
                }
            default:
                MobileTriviaDeckClueView()
            }
        }
        .withBackButton()
        .navigationBarTitle(exploreVM.currentTriviaDeck.title, displayMode: .inline)
        .animation(.easeInOut(duration: 0.2))
    }
}

enum TriviaDeckDisplayMode {
    case dailyChallengeClue, triviaDeckClue, buildingCustomClue
}

