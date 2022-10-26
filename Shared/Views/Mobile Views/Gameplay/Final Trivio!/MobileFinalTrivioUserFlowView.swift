//
//  MobileFinalTrivioMakeWagerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioUserFlowView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var isShowingInstructions = false
    
    var headingLabelText: String {
        switch gamesVM.finalTrivioStage {
        case .makeWager:
            return "WAGERS"
        case .submitAnswer:
            return "ANSWERS"
        case .revealResponse:
            return "RESULTS"
        default:
            return ""
        }
    }
    
    var guidanceLabelText: String {
        switch gamesVM.finalTrivioStage {
        case .makeWager:
            return """
            In the next screen, you will receive a clue under this category. Each player must wager some amount less than or equal to their own score. If your answer is correct, you will receive that amount. If not, your wager will be deducted from your total score.
            """
        case .submitAnswer:
            return """
            Submit your answer to the question above in under 30 seconds!
            """
        case .revealResponse:
            return """
            Reveal everyone’s answer one by one, and score accordingly.
            """
        default:
            return ""
        }
    }
    
    var body: some View {
        VStack {
            Text(gamesVM.fjCategory.uppercased())
                .font(formatter.font(.bold, fontSize: .mediumLarge))
                .padding()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(10)
            VStack {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack {
                        VStack {
                            HStack {
                                Text(headingLabelText)
                                    .font(formatter.font(.bold, fontSize: .medium))
                                Spacer()
                                Button(action: {
                                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                                    isShowingInstructions.toggle()
                                }, label: {
                                    Image(systemName: isShowingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                                        .font(formatter.iconFont(.small))
                                })
                            }
                            // Instructions (only shown if isShowingInstructions is true)
                            if isShowingInstructions {
                                Text(guidanceLabelText)
                                    .font(formatter.font(.regularItalic, fontSize: .small))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 20)
                            
                            // Each player's textbox for entering wagers
                            ForEach(participantsVM.teams, id: \.self) { team in
                                switch gamesVM.finalTrivioStage {
                                case .makeWager:
                                    MobileMakeWagerView(teamIndex: team.index)
                                case .submitAnswer:
                                    MobileSubmitAnswerView(teamIndex: team.index)
                                default:
                                    MobileMakeWagerView(teamIndex: team.index)
                                }
                            }
                        }
                    }
                    .padding()
                }
                // Continue button
                Button(action: {
                    if participantsVM.wagersValid() {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        gamesVM.finalTrivioFinishedAction()
                    }
                }, label: {
                    Text("Continue")
                        .foregroundColor(formatter.color(.primaryFG))
                        .font(formatter.font(fontSize: .regular))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.highContrastWhite))
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                        .padding([.horizontal, .bottom])
                        .opacity(participantsVM.wagersValid() ? 1 : 0.4)
                })
            }
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
        }
    }
}

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
                        .font(formatter.font(.boldItalic, fontSize: .mediumLarge))
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
