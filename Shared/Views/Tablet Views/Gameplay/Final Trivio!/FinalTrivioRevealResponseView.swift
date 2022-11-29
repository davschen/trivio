//
//  FinalTrivioRevealResponseView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/18/21.
//

import Foundation
import SwiftUI

struct FinalTrivioRevealResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        ScrollView (.vertical) {
            VStack (spacing: 15) {
                
                // Category name
                HStack {
                    Text(gamesVM.customSet.finalCat.uppercased())
                        .font(formatter.font())
                        .padding(20)
                        .frame(width: 350)
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(10)
                    Spacer()
                }
                
                // Final Trivio Clue
                Text(gamesVM.customSet.finalClue)
                    .font(formatter.font(fontSize: .mediumLarge))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Correct response revealed
                HStack (spacing: 15) {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 30))
                    Text("Correct Response:")
                    Text(gamesVM.customSet.finalResponse)
                        .foregroundColor(formatter.color(.secondaryAccent))
                    Spacer()
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .padding(30)
                .background(formatter.color(.primaryBG))
                .cornerRadius(10)
                
                // Reveal/grading scrollview
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 15) {
                        ForEach(participantsVM.teams, id: \.self) { team in
                            RevealGradeView(teamIndex: team.index)
                        }
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
                .keyboardAware()
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(30)
        }
        .background(formatter.color(.primaryAccent))
        .cornerRadius(40)
    }
}

struct RevealGradeView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    let teamIndex: Int
    
    var correct: Bool {
        return participantsVM.fjCorrects[teamIndex]
    }
    
    var incorrect: Bool {
        return participantsVM.toSubtracts[teamIndex]
    }
    
    var body: some View {
        VStack {
            
            // Reveals answer
            HStack {
                if !participantsVM.fjReveals[teamIndex] {
                    Text("Tap to Reveal")
                    Spacer()
                    Image("eye")
                } else {
                    Text(participantsVM.finalJeopardyAnswers[teamIndex])
                        .frame(maxWidth: .infinity)
                }
            }
            .font(formatter.font(fontSize: .mediumLarge))
            .padding(30)
            .frame(height: 90)
            .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .primaryFG : .lowContrastWhite))
            .contentShape(Rectangle())
            .cornerRadius(10)
            .onTapGesture {
                if !participantsVM.fjReveals[teamIndex] {
                    participantsVM.fjReveals[teamIndex].toggle()
                    participantsVM.setSelectedTeam(index: teamIndex)
                }
            }
            
            // View and grade answer
            VStack (spacing: 10) {
                
                // Grade answer
                HStack {
                    Button(action: {
                        if self.participantsVM.fjCorrects[teamIndex] {
                            self.participantsVM.addFJCorrect(index: teamIndex)
                        }
                        self.participantsVM.addFJIncorrect(index: teamIndex)
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(formatter.color(incorrect ? .highContrastWhite : .lowContrastWhite))
                            .frame(maxWidth: .infinity)
                    })
                    Text(participantsVM.teams[teamIndex].name)
                        .font(formatter.font(fontSize: .mediumLarge))
                    Button(action: {
                        if self.participantsVM.toSubtracts[teamIndex] {
                            self.participantsVM.addFJIncorrect(index: teamIndex)
                        }
                        self.participantsVM.addFJCorrect(index: teamIndex)
                    }, label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(formatter.color(correct ? .highContrastWhite : .lowContrastWhite))
                            .frame(maxWidth: .infinity)
                    })
                }
                
                // View wager if not hidden
                Text(!participantsVM.fjReveals[teamIndex] ? "" : ("Wager: $" + participantsVM.wagers[teamIndex]))
                    .font(formatter.font())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .secondaryFG : (correct ? .green : (incorrect ? .red : .secondaryFG))))
                    .cornerRadius(5)
            }
            .padding(20)
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
        }
        .frame(width: getSuggestedWidth())
    }
    
    func getSuggestedWidth() -> CGFloat {
        if participantsVM.teams.count > 3 {
            return (UIScreen.main.bounds.width - (120 + CGFloat(15 * (participantsVM.teams.count - 1)))) * CGFloat(1 / Double(3))
        } else {
            return (UIScreen.main.bounds.width - (120 + CGFloat(15 * (participantsVM.teams.count - 1)))) * CGFloat(1 / Double(participantsVM.teams.count))
        }
    }
}
