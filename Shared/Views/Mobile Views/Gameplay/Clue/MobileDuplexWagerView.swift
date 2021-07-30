//
//  MobileDuplexWagerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileDuplexWagerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var ddWagerMade: Bool
    @Binding var wager: Double
    
    let clue: String
    
    var maxScore: Int {
        if gamesVM.gamePhase == .trivio {
            return 1000
        } else {
            return 2000
        }
    }
    
    var body: some View {
        VStack {
            Text("DUPLEX OF THE DAY")
                .font(formatter.font(fontSize: .large))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                .multilineTextAlignment(.center)
            VStack {
                Slider(value: $wager, in: 0...Double(max(maxScore, participantsVM.teams.indices.contains(participantsVM.selectedTeam.index) ? participantsVM.teams[participantsVM.selectedTeam.index].score : 0)), step: 100)
                    .accentColor(formatter.color(.secondaryAccent))
                    .foregroundColor(formatter.color(.mediumContrastWhite))
                HStack {
                    Text("Wager: \(Int(self.wager))")
                        .font(formatter.font())
                        .multilineTextAlignment(.center)
                    Spacer(minLength: 30)
                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        self.ddWagerMade.toggle()
                        self.formatter.speaker.speak(clue)
                    }) {
                        Text("Done")
                            .font(formatter.font())
                            .padding(15)
                            .background(formatter.color(.lowContrastWhite))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

