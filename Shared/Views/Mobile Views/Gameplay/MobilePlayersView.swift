//
//  MobilePlayersView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import MovingNumbersView

struct MobilePlayersView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        // Contestants HStack
        if participantsVM.teams.count > 0 {
            HStack (spacing: 5) {
                ForEach(participantsVM.teams) { team in
                    VStack (alignment: .leading, spacing: 0) {
                        HStack (spacing: 5) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(ColorMap().getColor(color: team.color))
                            VStack (alignment: .leading) {
                                Text("\(team.name)")
                                    .font(formatter.font(fontSize: participantsVM.teams.count > 3 ? .medium : .mediumLarge))
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                if team.members.count > 0 {
                                    HStack (spacing: 3) {
                                        Image(systemName: "mic.fill")
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                            .font(formatter.iconFont(.small))
                                        Text(participantsVM.spokespeople[team.index])
                                            .font(formatter.font(.regularItalic, fontSize: .small))
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                    }
                                }
                            }
                        }
                        HStack (spacing: 0) {
                            Text("\(team.score >= 0 ? "$" : "-$")")
                                .font(formatter.font(fontSize: .mediumLarge))
                            MovingNumbersView(
                                number: Double(abs(team.score)),
                                numberOfDecimalPlaces: 0) { str in
                                    Text(str)
                                        .font(formatter.font(fontSize: .mediumLarge))
                            }
                        }
                        .foregroundColor(formatter.color(team.score < 0 ? .red : .highContrastWhite))
                        .frame(maxWidth: .infinity)
                        .frame(height: 35)
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(5)
                    }
                    .padding(participantsVM.teams.count > 2 ? 10 : 15)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(formatter.color(.highContrastWhite), lineWidth: participantsVM.selectedTeam == team ? 5 : 0))
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(10)
                    .onTapGesture {
                        if !(participantsVM.selectedTeam == team) {
                            participantsVM.setSelectedTeam(index: team.index)
                        }
                    }
                    .onAppear {
                        if participantsVM.selectedTeam.name.isEmpty {
                            participantsVM.setSelectedTeam(index: 0)
                        }
                    }
                }
            }
            .padding(.vertical, 5)
        } else {
            Button(action: {
                gamesVM.gameSetupMode = .participants
            }, label: {
                HStack {
                    Text("Looks like you haven't set up any contestants - Tap to set up contestants")
                        .font(formatter.font(.regularItalic, fontSize: .mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, formatter.padding(size: 25))
                .background(formatter.color(.secondaryFG))
                .cornerRadius(formatter.cornerRadius(iPadSize: 5))
                .padding(.bottom, 10)
            })
        }
    }
}

