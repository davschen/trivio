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

struct MobileRevealGradeView: View {
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
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .primaryFG : .lowContrastWhite))
            .contentShape(Rectangle())
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
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
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
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
                        formatter.hapticFeedback(style: .heavy, intensity: .strong)
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
            .padding()
            .background(formatter.color(.primaryFG))
            .cornerRadius(5)
        }
        .frame(maxWidth: .infinity)
    }
}

