//
//  MobileFinalTrivioView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct MobileFinalTrivioView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var finalJeopardyReveal = false
    @State var musicPlaying = false
    @State var rating = 0
    
    var body: some View {
        ZStack {
            switch gamesVM.finalTrivioStage {
            case .makeWager:
                MobileFinalTrivioMakeWagerView()
                    .transition(AnyTransition.move(edge: .leading))
            case .submitAnswer:
                MobileFinalTrivioSubmitAnswerView()
                    .transition(AnyTransition.move(edge: .leading))
            case .revealResponse:
                MobileFinalTrivioRevealResponseView()
                    .transition(AnyTransition.move(edge: .leading))
            default:
                MobileFinalTrivioPodiumView()
                    .transition(AnyTransition.move(edge: .leading))
            }
        }
    }
}

struct MobileFinalTrivioCountdownTimerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var timeRemaining: Double = 30
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .frame(width: geometry.size.width)
                .foregroundColor(formatter.color(.primaryAccent))
            Rectangle()
                .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 30) : 0)
                .foregroundColor(formatter.color(.secondaryAccent))
                .animation(.linear(duration: 1))
        }
        .frame(height: 10)
        .clipShape(Capsule())
        .onReceive(timer) { time in
            self.timeRemaining -= 1
        }
    }
}

