//
//  PlayersView.swift
//  Trivio!
//
//  Created by David Chen on 7/9/21.
//

import Foundation
import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel

    var body: some View {
        // Contestants HStack
        if participantsVM.teams.count > 0 {
            HStack (spacing: 15) {
                ForEach(participantsVM.teams) { team in
                    VStack (spacing: 0) {
                        HStack (spacing: 15) {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(ColorMap().getColor(color: team.color))
                            VStack (alignment: .leading) {
                                Text("\(team.name)")
                                    .font(formatter.font(fontSize: participantsVM.teams.count > 3 ? .mediumLarge : .large))
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                if team.members.count > 0 {
                                    HStack {
                                        Image(systemName: "mic.fill")
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                            .font(.system(size: 15))
                                        Text(self.participantsVM.spokespeople[team.index])
                                            .font(formatter.font(.regularItalic))
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                    }
                                }
                            }
                            Spacer(minLength: 0)
                            Text("\(team.score >= 0 ? "$" : "-$")\(abs(team.score))")
                                .font(formatter.font(fontSize: .mediumLarge))
                                .foregroundColor(formatter.color(team.score < 0 ? .red : .highContrastWhite))
                                .frame(maxWidth: 130)
                                .frame(maxHeight: .infinity)
                                .background(formatter.color(.primaryFG))
                                .cornerRadius(15)
                                .minimumScaleFactor(0.1)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: self.participantsVM.selectedTeam == team ? 10 : 0))
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(20)
                    .onTapGesture {
                        if !(self.participantsVM.selectedTeam == team) {
                            self.participantsVM.setSelectedTeam(index: team.index)
                        }
                    }
                    .onAppear {
                        if participantsVM.selectedTeam.name.isEmpty {
                            self.participantsVM.setSelectedTeam(index: 0)
                        }
                    }
                }
            }
            .padding(.vertical, 5)
        } else {
            Button(action: {
                gamesVM.menuChoice = .participants
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
