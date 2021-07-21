//
//  FinalTrivioMakeWagerView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/17/21.
//

import Foundation
import SwiftUI

struct FinalTrivioMakeWagerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var isShowingInstructions = false
    
    var body: some View {
        VStack (spacing: 15) {
            // Category name view
            ZStack (alignment: .topTrailing) {
                Text(gamesVM.fjCategory.uppercased())
                    .font(formatter.font())
                    .padding()
                    .frame(width: 350, height: 150)
                    .background(formatter.color(.lowContrastWhite))
                    .cornerRadius(10)
                Button(action: {
                    isShowingInstructions.toggle()
                }, label: {
                    Image(systemName: isShowingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                        .font(.system(size: 20))
                        .padding(10)
                })
            }
            
            // Instructions (only shown if isShowingInstructions is true)
            if isShowingInstructions {
                Text("In the next screen, you will receive a question under this category. Each player must wager a dollar amount up to their own score. If your answer is correct, you will receive that amount. If not, your wager will be deducted from your total score.")
                    .font(formatter.font(.regularItalic))
            }
            
            // Make wagers scrollview
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 15) {
                    ForEach(participantsVM.teams, id: \.self) { team in
                        MakeWagerView(teamIndex: team.index)
                    }
                }
            }
            
            // Finished button
            Button(action: {
                if participantsVM.wagersValid() {
                    gamesVM.finalTrivioFinishedAction()
                }
            }, label: {
                Text("Finished")
                    .font(formatter.font())
                    .padding(20)
                    .padding(.horizontal, 20)
                    .background(formatter.color(.lowContrastWhite))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(participantsVM.wagersValid() ? 1 : 0.5)
            })
            .keyboardAware()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(40)
    }
}

struct MakeWagerView: View {
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
        VStack (alignment: .leading) {
            HStack (spacing: 10) {
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .large))
            }
            ZStack {
                if hidden {
                    HStack {
                        Text("$")
                        Text(wagerMade ? "Wager made" : "Make your wager")
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
                        SecureField("Enter your wager", text: $participantsVM.wagers[teamIndex])
                            .keyboardType(.numberPad)
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
            .padding(30)
            .frame(width: getSuggestedWidth())
            .background(formatter.color(hidden ? .primaryFG : .lowContrastWhite))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .onTapGesture {
                if hidden {
                    hidden.toggle()
                }
            }
            if !participantsVM.wagers.isEmpty && !invalidWagerString(teamIndex: teamIndex).isEmpty {
                Text(invalidWagerString(teamIndex: teamIndex))
                    .font(formatter.font(.regularItalic))
                    .foregroundColor(formatter.color(.secondaryAccent))
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    func getSuggestedWidth() -> CGFloat {
        if participantsVM.teams.count > 3 {
            return (UIScreen.main.bounds.width - (120 + CGFloat(15 * (participantsVM.teams.count - 1)))) * CGFloat(1 / Double(3))
        } else {
            return (UIScreen.main.bounds.width - (120 + CGFloat(15 * (participantsVM.teams.count - 1)))) * CGFloat(1 / Double(participantsVM.teams.count))
        }
    }
    
    func invalidWagerString(teamIndex: Int) -> String {
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
