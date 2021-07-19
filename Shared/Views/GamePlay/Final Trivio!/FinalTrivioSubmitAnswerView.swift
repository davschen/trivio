//
//  FinalTrivioSubmitAnswerView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/18/21.
//

import Foundation
import SwiftUI

struct FinalTrivioSubmitAnswerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        VStack (spacing: 15) {
            
            // Category name
            Text(gamesVM.fjCategory.uppercased())
                .font(formatter.font())
                .padding()
                .frame(width: 350, height: 150)
                .background(formatter.color(.lowContrastWhite))
                .cornerRadius(10)
            
            // Final Trivio Clue
            Text(gamesVM.fjClue)
                .font(formatter.font(fontSize: .large))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 100)
                .padding()
            
            // Vertical scrollview for answer submissions
            ScrollView (.vertical, showsIndicators: false) {
                VStack {
                    ForEach(participantsVM.teams, id: \.self) { team in
                        SubmitAnswerView(teamIndex: team.index)
                    }
                }
                // Finished button
                Button(action: {
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
            }
            .keyboardAware()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(40)
    }
}

struct SubmitAnswerView: View {
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
        HStack {
            HStack (spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .large))
                Spacer()
            }
            .frame(width: 200)
            
            // Submit your answer textfield
            HStack {
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
                                    .frame(width: 39, height: 37)
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
                                    .frame(width: 39, height: 37)
                            })
                        }
                    }
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(formatter.color(answerSubmitted ? .highContrastWhite : .mediumContrastWhite))
                .padding(30)
                .frame(maxWidth: .infinity)
                .background(formatter.color(hidden ? .primaryFG : .lowContrastWhite))
                .cornerRadius(10)
            }
        }
    }
}
