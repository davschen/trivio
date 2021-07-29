//
//  MobileFinalTrivioMakeWagerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileFinalTrivioMakeWagerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var isShowingInstructions = false
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (spacing: 15) {
                // Category name view
                ZStack (alignment: .topTrailing) {
                    Text(gamesVM.fjCategory.uppercased())
                        .font(formatter.font())
                        .padding()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(10)
                    Button(action: {
                        isShowingInstructions.toggle()
                    }, label: {
                        Image(systemName: isShowingInstructions ? "questionmark.circle.fill" : "questionmark.circle")
                            .font(formatter.iconFont())
                            .padding(10)
                    })
                }
                
                // Instructions (only shown if isShowingInstructions is true)
                if isShowingInstructions {
                    Text("In the next screen, you will receive a question under this category. Each player must wager a dollar amount up to their own score. If your answer is correct, you will receive that amount. If not, your wager will be deducted from your total score.")
                        .font(formatter.font(.regularItalic, fontSize: .small))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Make wagers scrollview
                VStack {
                    ForEach(participantsVM.teams, id: \.self) { team in
                        MobileMakeWagerView(teamIndex: team.index)
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
                        .padding()
                        .padding(.horizontal)
                        .background(formatter.color(.lowContrastWhite))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .opacity(participantsVM.wagersValid() ? 1 : 0.5)
                })
                .keyboardAware()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(formatter.color(.primaryAccent))
        .cornerRadius(20)
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
        VStack (alignment: .leading) {
            HStack (spacing: 10) {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(ColorMap().getColor(color: team.color))
                Text(team.name)
                    .font(formatter.font(fontSize: .semiLarge))
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
                                .frame(width: 25, height: 24)
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
                                .frame(width: 25, height: 24)
                        })
                    }
                }
            }
            .font(formatter.font(fontSize: .medium))
            .padding()
            .frame(maxWidth: .infinity)
            .background(formatter.color(hidden ? .primaryFG : .lowContrastWhite))
            .cornerRadius(5)
            .contentShape(Rectangle())
            .onTapGesture {
                if hidden {
                    hidden.toggle()
                }
            }
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

