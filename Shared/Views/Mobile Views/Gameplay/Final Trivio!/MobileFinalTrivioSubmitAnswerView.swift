//
//  MobileFinalTrivioSubmitAnswerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioSubmitAnswerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (spacing: 15) {
                
                // Category name
                Text(gamesVM.fjCategory.uppercased())
                    .font(formatter.font())
                    .padding()
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(10)
                
                // Final Trivio Clue
                Text(gamesVM.fjClue.uppercased())
                    .font(formatter.font())
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding()
                    .onAppear {
                        formatter.speaker.speak(gamesVM.fjClue)
                    }
                
                // Answer submissions
                VStack {
                    ForEach(participantsVM.teams, id: \.self) { team in
                        MobileSubmitAnswerView(teamIndex: team.index)
                    }
                }
                // Finished button
                Button(action: {
                    if participantsVM.answersValid() {
                        gamesVM.finalTrivioFinishedAction()
                    }
                }, label: {
                    Text("Finished")
                        .font(formatter.font())
                        .padding()
                        .padding(.horizontal)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .opacity(participantsVM.answersValid() ? 1 : 0.5)
                })
                .keyboardAware()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
    }
}

struct MobileSubmitAnswerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var hidden = false
    
    let teamIndex: Int
    
    var team: Team {
        return participantsVM.teams[teamIndex]
    }
    
    var answerSubmitted: Bool {
        let answer = participantsVM.finalJeopardyAnswers[teamIndex]
        return !answer.isEmpty
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (spacing: 10) {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .semiLarge))
                    .minimumScaleFactor(0.3)
                Spacer()
            }
            
            // Submit your answer textfield
            ZStack {
                if hidden {
                    HStack {
                        Text("$")
                        Text(answerSubmitted ? "Answer submitted!" : "Submit your answer")
                            .lineLimit(1)
                            .minimumScaleFactor(0.3)
                        Spacer()
                        Button(action: {
                            hidden.toggle()
                        }, label: {
                            Image("eye")
                                .frame(width: 25, height: 24)
                        })
                    }
                } else {
                    HStack {
                        Text("$")
                        SecureField("Submit your answer", text: $participantsVM.finalJeopardyAnswers[teamIndex])
                        Spacer()
                        Button(action: {
                            hidden.toggle()
                        }, label: {
                            Image("eye.slash")
                                .frame(width: 25, height: 24)
                        })
                    }
                }
            }
            .font(formatter.font(fontSize: .medium))
            .foregroundColor(formatter.color(answerSubmitted ? .highContrastWhite : .mediumContrastWhite))
            .padding()
            .frame(maxWidth: .infinity)
            .background(formatter.color(hidden ? .primaryFG : .lowContrastWhite))
            .cornerRadius(5)
        }
    }
}

