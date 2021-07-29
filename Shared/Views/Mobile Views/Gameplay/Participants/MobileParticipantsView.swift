//
//  MobileParticipantsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileParticipantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var showsBuild = false
    @State var teamToEdit = Empty().team
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            VStack (spacing: 15) {
                // Header
                MobileParticipantsHeaderView(showsBuild: $showsBuild, teamToEdit: $teamToEdit)
                
                // All saved players
                MobileSavedPlayersView()
                
                // All active participants
                MobileActiveParticipantsView(showsBuild: $showsBuild, teamToEdit: $teamToEdit)
            }
            .padding([.horizontal, .top])
            MobileTeamBuildView(showsBuild: $showsBuild, team: participantsVM.teams.indices.contains(teamToEdit.index) ? $participantsVM.teams[teamToEdit.index] : $teamToEdit)
        }
    }
}

struct MobileParticipantsHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showsBuild: Bool
    @Binding var teamToEdit: Team
    
    var body: some View {
        VStack (spacing: formatter.shrink(iPadSize: 15)) {
            HStack {
                Text("\(participantsVM.isTeams ? "Teams" : "Contestants")")
                    .font(formatter.font(fontSize: .extraLarge))
                Button (action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    participantsVM.addTeam(name: "", members: [], score: 0, color: "blue")
                    teamToEdit = participantsVM.teams.last!
                    showsBuild.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(formatter.iconFont(.mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .padding(5)
                }
                Spacer()
            }
            Button(action: {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                participantsVM.isTeams.toggle()
            }, label: {
                Text("Switch to \(participantsVM.isTeams ? "Contestants" : "Teams")")
                    .font(formatter.font())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
            })
            Button(action: {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                gamesVM.gameSetupMode = .settings
            }, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(formatter.iconFont())
                    Text("Play")
                }
                .font(formatter.font())
                .foregroundColor(formatter.color(.primaryFG))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.highContrastWhite))
                .cornerRadius(5)
            })
        }
    }
}

struct MobileSavedPlayersView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Saved Players")
                .font(formatter.font(fontSize: .mediumLarge))
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(participantsVM.historicalTeams) { team in
                        HStack {
                            Circle()
                                .foregroundColor(ColorMap().getColor(color: team.color))
                                .frame(width: 10, height: 10)
                            Text(team.name)
                                .font(formatter.font())
                                .foregroundColor(formatter.color(.highContrastWhite))
                            
                            // Delete button, only if saved user is not self
                            if let uid = profileVM.myUID {
                                if team.id != uid {
                                    Button(action: {
                                        formatter.setAlertSettings(alertAction: {
                                            participantsVM.removeTeamFromFirestore(id: team.id)
                                        }, alertTitle: "Delete Player?", alertSubtitle: "If you delete \(team.name), you'll have to add them back later manually.", hasCancel: true, actionLabel: "Delete")
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                    })
                                    .padding(.leading, 10)
                                }
                            }
                        }
                        .padding()
                        .frame(height: 50)
                        .background(formatter.color(participantsVM.teams.contains(team) ? .primaryAccent : .secondaryFG))
                        .cornerRadius(5)
                        .onTapGesture {
                            formatter.hapticFeedback(style: .soft)
                            if !participantsVM.teams.contains(team) {
                                participantsVM.addTeam(id: team.id, name: team.name, members: team.members, score: 0, color: team.color)
                            } else {
                                participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(formatter.color(.primaryFG))
        .cornerRadius(5)
    }
}

struct MobileActiveParticipantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var showsBuild: Bool
    @Binding var teamToEdit: Team
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (spacing: 15) {
                ForEach(participantsVM.teams) { team in
                    VStack {
                        HStack (spacing: 15) {
                            Circle()
                                .frame(width: 15, height: 15)
                                .foregroundColor(ColorMap().getColor(color: team.color))
                            Text(team.name.isEmpty ? "" : team.name + (participantsVM.isTeams ? " (\(team.members.count))" : ""))
                                .font(formatter.font(fontSize: .large))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Spacer()
                            Button(action: {
                                if gamesVM.gameInProgress() {
                                    formatter.setAlertSettings(alertAction: {
                                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                                        participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                    }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                                } else {
                                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                                    participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                }
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(formatter.iconFont(.large))
                            })
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(formatter.color(.primaryAccent))
                        .cornerRadius(10)
                        .onTapGesture {
                            formatter.hapticFeedback(style: .medium)
                            teamToEdit = team
                            showsBuild.toggle()
                        }
                        
                        if participantsVM.isTeams {
                            VStack {
                                // Add member textfield
                                MobileAddMemberTextFieldView(teamIndex: team.index)
                                
                                ScrollView (.horizontal, showsIndicators: false) {
                                    HStack {
                                        // Members Scrollview
                                        ForEach(team.members, id: \.self) { member in
                                            HStack {
                                                Text(member)
                                                    .font(formatter.font())
                                                    .foregroundColor(formatter.color(.highContrastWhite))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                Spacer()
                                                Button(action: {
                                                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                                                    participantsVM.removeMember(index: team.index, name: member)
                                                }, label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .font(formatter.iconFont())
                                                        .foregroundColor(formatter.color(.highContrastWhite))
                                                })
                                            }
                                            .padding(10)
                                            .background(formatter.color(.secondaryFG))
                                            .cornerRadius(5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MobileAddMemberTextFieldView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var newMemberName = ""
    
    let teamIndex: Int
    
    var body: some View {
        HStack {
            TextField("Add Name", text: $newMemberName)
                .font(formatter.font(fontSize: .large))
            Button(action: {
                participantsVM.teams[teamIndex].addMember(name: newMemberName)
                newMemberName.removeAll()
            }, label: {
                Image(systemName: "plus")
                    .font(formatter.iconFont(.large))
                    .foregroundColor(formatter.color(newMemberName.isEmpty ? .lowContrastWhite : .highContrastWhite))
            })
        }
        .padding()
        .background(formatter.color(.primaryFG))
        .accentColor(formatter.color(.secondaryAccent))
        .cornerRadius(10)
    }
}

