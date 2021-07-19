//
//  FinalJeopardyView.swift
//  Trivio
//
//  Created by David Chen on 2/9/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct FinalJeopardyView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var finalJeopardySelected: Bool
    
    @State var finalJeopardyReveal = false
    @State var musicPlaying = false
    @State var rating = 0
    
    var body: some View {
        VStack (spacing: 15) {
            HStack {
                Text("Final Trivio! Round")
                    .font(formatter.font(fontSize: .large))
                Spacer()
            }
            ZStack {
                switch gamesVM.finalTrivioStage {
                case .makeWager:
                    FinalTrivioMakeWagerView()
                case .submitAnswer:
                    FinalTrivioSubmitAnswerView()
                case .revealResponse:
                    FinalTrivioRevealResponseView()
                default:
                    FinalTrivioPodiumView(finalJeopardySelected: $finalJeopardySelected)
                }
            }
            .transition(.slide)
        }
    }
}

struct FinalTrivioCountdownTimerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var timeRemaining: Double = 30
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 30) : 0)
                .foregroundColor(formatter.color(.secondaryAccent))
                .animation(.easeInOut(duration: 1))
        }
        .frame(height: 20)
        .clipShape(Capsule())
        .padding(.horizontal, formatter.padding())
        .onReceive(timer) { time in
            self.timeRemaining -= 1
        }
    }
}
