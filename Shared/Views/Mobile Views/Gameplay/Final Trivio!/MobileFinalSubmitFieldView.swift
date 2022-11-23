//
//  MobileFinalTrivioSubmitAnswerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileMakeWagerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var hidden = false
    
    let teamIndex: Int
    
    var team: Team {
        return participantsVM.teams[teamIndex]
    }
    
    var wagerMade: Bool {
        let wager = participantsVM.wagers[teamIndex]
        return !wager.isEmpty && (Int(wager) != nil) && (Int(wager)! >= 0)
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack (spacing: 5) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .medium))
            }
            HStack {
                if hidden {
                    Text(wagerMade ? "Wager made" : "Make your wager")
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(formatter.font(.boldItalic, fontSize: .medium))
                } else {
                    SecureField("Enter your wager", text: $participantsVM.wagers[teamIndex])
                        .keyboardType(.numberPad)
                }
                Spacer()
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    hidden.toggle()
                }, label: {
                    Text("\(hidden ? "Edit" : "Done")")
                        .foregroundColor(formatter.color(.secondaryAccent))
                })
            }
            .font(formatter.font(fontSize: .medium))
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(formatter.color(hidden ? .primaryAccent : .secondaryFG))
            .cornerRadius(5)
            .contentShape(Rectangle())
            
            if !invalidWagerString(teamIndex: teamIndex).isEmpty {
                Text(invalidWagerString(teamIndex: teamIndex))
                    .font(formatter.font(.regularItalic))
                    .foregroundColor(formatter.color(.secondaryAccent))
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    func invalidWagerString(teamIndex: Int) -> String {
        if participantsVM.wagers[teamIndex].isEmpty {
            return ""
        }
        if Int(participantsVM.wagers[teamIndex]) == nil {
            return "You must enter a number"
        } else if Int(participantsVM.wagers[teamIndex])! > participantsVM.teams[teamIndex].score {
            return "Your wager cannot be higher than your score"
        } else if Int(participantsVM.wagers[teamIndex])! < 0 {
            return "Your wager cannot be negative. Nice try though."
        }
        return ""
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
                    .frame(width: 6, height: 6)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .medium))
                    .minimumScaleFactor(0.3)
                Spacer()
            }
            
            // Submit your answer textfield
            HStack {
                if hidden {
                    Text(answerSubmitted ? "Answer submitted!" : "Submit your answer")
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .font(formatter.font(.boldItalic, fontSize: .medium))
                } else {
                    SecureField("Enter your answer", text: $participantsVM.finalJeopardyAnswers[teamIndex])
                }
                Spacer()
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    hidden.toggle()
                }, label: {
                    Text("\(hidden ? "Edit" : "Done")")
                        .foregroundColor(formatter.color(.secondaryAccent))
                })
            }
            .font(formatter.font(fontSize: .medium))
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(formatter.color(hidden ? .primaryAccent : .secondaryFG))
            .cornerRadius(5)
            .contentShape(Rectangle())
        }
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
            HStack (spacing: 10) {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundColor(ColorMap().getColor(color: participantsVM.teams[teamIndex].color))
                Text(participantsVM.teams[teamIndex].name)
                    .font(formatter.font(fontSize: .medium))
                    .minimumScaleFactor(0.3)
                Spacer()
            }
            
            // Reveals answer
            HStack {
                if !participantsVM.fjReveals[teamIndex] {
                    Text("REVEAL")
                        .font(formatter.font(.boldItalic, fontSize: .mediumLarge))
                } else {
                    Button {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        if self.participantsVM.fjCorrects[teamIndex] {
                            self.participantsVM.addFJCorrect(index: teamIndex)
                        }
                        self.participantsVM.addFJIncorrect(index: teamIndex)
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 70, height: 70)
                            .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .secondaryFG : (correct ? .green : (incorrect ? .red : .lowContrastWhite))))
                    }
                    VStack {
                        Text(participantsVM.finalJeopardyAnswers[teamIndex])
                        Text(!participantsVM.fjReveals[teamIndex] ? "" : ("Wager: " + participantsVM.wagers[teamIndex]))
                            .foregroundColor(formatter.color(incorrect ? .red : .green))
                            .font(formatter.font(.boldItalic, fontSize: .small))
                    }
                    .frame(maxWidth: .infinity)
                    Button {
                        formatter.hapticFeedback(style: .heavy, intensity: .strong)
                        if self.participantsVM.toSubtracts[teamIndex] {
                            self.participantsVM.addFJIncorrect(index: teamIndex)
                        }
                        self.participantsVM.addFJCorrect(index: teamIndex)
                    } label: {
                        Image(systemName: "checkmark")
                            .frame(width: 70, height: 70)
                            .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .secondaryFG : (correct ? .green : (incorrect ? .red : .lowContrastWhite))))
                    }
                }
            }
            .font(formatter.font(fontSize: .medium))
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .secondaryFG : .primaryAccent))
            .contentShape(Rectangle())
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                participantsVM.fjReveals[teamIndex].toggle()
                participantsVM.setSelectedTeam(index: teamIndex)
            }
//
//            // View and grade answer
//            VStack (spacing: 10) {
//
//                // Grade answer
//                HStack {
//                    Button(action: {
//                        formatter.hapticFeedback(style: .soft, intensity: .strong)
//                        if self.participantsVM.fjCorrects[teamIndex] {
//                            self.participantsVM.addFJCorrect(index: teamIndex)
//                        }
//                        self.participantsVM.addFJIncorrect(index: teamIndex)
//                    }, label: {
//                        Image(systemName: "xmark")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(formatter.color(incorrect ? .highContrastWhite : .lowContrastWhite))
//                            .frame(maxWidth: .infinity)
//                    })
//                    Text(participantsVM.teams[teamIndex].name)
//                        .font(formatter.font(fontSize: .mediumLarge))
//                    Button(action: {
//                        formatter.hapticFeedback(style: .heavy, intensity: .strong)
//                        if self.participantsVM.toSubtracts[teamIndex] {
//                            self.participantsVM.addFJIncorrect(index: teamIndex)
//                        }
//                        self.participantsVM.addFJCorrect(index: teamIndex)
//                    }, label: {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(formatter.color(correct ? .highContrastWhite : .lowContrastWhite))
//                            .frame(maxWidth: .infinity)
//                    })
//                }
//
//                // View wager if not hidden
//                Text(!participantsVM.fjReveals[teamIndex] ? "" : ("Wager: $" + participantsVM.wagers[teamIndex]))
//                    .font(formatter.font())
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(formatter.color(!participantsVM.fjReveals[teamIndex] ? .secondaryFG : (correct ? .green : (incorrect ? .red : .secondaryFG))))
//                    .cornerRadius(5)
//            }
//            .padding()
//            .background(formatter.color(.primaryFG))
//            .cornerRadius(5)
        }
        .frame(maxWidth: .infinity)
    }
}

