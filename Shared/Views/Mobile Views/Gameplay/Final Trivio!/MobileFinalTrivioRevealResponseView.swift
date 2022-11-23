//
//  MobileFinalTrivioRevealResponseView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioRevealResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        ScrollView (.vertical) {
            VStack (spacing: 15) {
                
                // Category name
                HStack {
                    Text(gamesVM.fjCategory.uppercased())
                        .fixedSize(horizontal: false, vertical: true)
                        .font(formatter.font())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(10)
                    Spacer()
                }
                
                // Final Trivio Clue
                Text(gamesVM.fjClue)
                    .font(formatter.font())
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Correct response revealed
                VStack (spacing: 15) {
                    HStack (spacing: 15) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 30))
                        Text("Correct Response")
                        Spacer()
                    }
                    Text(gamesVM.fjResponse)
                        .foregroundColor(formatter.color(.secondaryAccent))
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .padding()
                .background(formatter.color(.primaryBG))
                .cornerRadius(10)
                
                // Reveal/grading scrollview
                VStack {
                    ForEach(participantsVM.teams, id: \.self) { team in
                        MobileRevealGradeView(teamIndex: team.index)
                    }
                }
                
                // Finished button
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    gamesVM.finalTrivioFinishedAction()
                }, label: {
                    Text("Finished")
                        .font(formatter.font())
                        .padding(20)
                        .padding(.horizontal, 20)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

