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
    
    @State var questionIsSelected = false
    
    let category: String
    let clue: String
    
    var maxScore: Int {
        if gamesVM.gamePhase == .trivio {
            return 1000
        } else {
            return 2000
        }
    }
    
    var body: some View {
        VStack (spacing: 20) {
            HStack (alignment: .top) {
                Text(category)
                    .font(formatter.font(fontSize: .medium))
                Spacer()
                Button {
                    questionIsSelected.toggle()
                } label: {
                    Image(systemName: questionIsSelected ? "questionmark.circle.fill" : "questionmark.circle")
                        .font(formatter.iconFont(.small))
                }
            }
            HStack {
                Text("Duplex of the Day")
                    .font(formatter.font(fontSize: .extraLarge))
                    .frame(width: 200, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 20)
                Spacer()
            }
            
            HStack {
                Text("\(participantsVM.teams[participantsVM.selectedTeam.index].name), make a wager:")
                Spacer()
                Text("\(Int(self.wager))")
            }
            .font(formatter.font(.regular, fontSize: .medium))
            VStack {
                Slider(value: $wager, in: 0...Double(max(maxScore, participantsVM.teams.indices.contains(participantsVM.selectedTeam.index) ? participantsVM.teams[participantsVM.selectedTeam.index].score : 0)), step: 100)
                    .accentColor(formatter.color(.secondaryAccent))
                    .foregroundColor(formatter.color(.mediumContrastWhite))
            }
            if questionIsSelected {
                Text("""
                Select a wager using the slider above. Game show rules apply to wager amounts. The number you choose will either be added or subtracted from your score, depending on if you get it right.

                When you tap the button at the bottom of the screen, a question will appear. Only the contestant highlighted (\(participantsVM.teams[participantsVM.selectedTeam.index].name) may answer. If the answer given is correct, reward David the points. If the answer given is incorrect, subtract the points. When finished, tap anywhere to proceed.
                """)
                    .font(formatter.font(.regularItalic, fontSize: .small))
            }
            Spacer()
            Button {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                self.ddWagerMade.toggle()
                self.formatter.speaker.speak(clue)
            } label: {
                Text("Show me the clue")
                    .font(formatter.font(fontSize: .regular))
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .clipShape(Capsule())
                    .background(Capsule().stroke(formatter.color(.highContrastWhite), lineWidth: 2))
                    .contentShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(formatter.color(.primaryAccent))
        .cornerRadius(10)
    }
}

