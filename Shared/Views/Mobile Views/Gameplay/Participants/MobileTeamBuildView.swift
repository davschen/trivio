//
//  MobileTeamBuildView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileTeamBuildView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var showsBuild: Bool
    @Binding var team: Team
    
    @State var nameToAdd = ""
    @State var scoreToAdd = ""
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(showsBuild ? 0.6 : 0)
                .onTapGesture {
                    formatter.hapticFeedback(style: .soft)
                    dismissBuild()
                }
            
            VStack (spacing: 10) {
                
                // Add or edit name textfield
                TextField("Add Name", text: $team.name)
                    .font(formatter.font(fontSize: .large))
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    .accentColor(formatter.color(.secondaryAccent))
                    .cornerRadius(10)
                
                // Color pickers (choose from 6 colors)
                HStack (spacing: 5) {
                    ColorPickerView(team: $team, color: formatter.color(.blue), colorString: "blue")
                    ColorPickerView(team: $team, color: formatter.color(.purple), colorString: "purple")
                    ColorPickerView(team: $team, color: formatter.color(.green), colorString: "green")
                    ColorPickerView(team: $team, color: formatter.color(.yellow), colorString: "yellow")
                    ColorPickerView(team: $team, color: formatter.color(.orange), colorString: "orange")
                    ColorPickerView(team: $team, color: formatter.color(.red), colorString: "red")
                }
                
                // Remove team/contestant button and toggle save
                HStack {
                    Button {
                        if gamesVM.gameInProgress() {
                            formatter.setAlertSettings(alertAction: {
                                formatter.hapticFeedback(style: .soft, intensity: .strong)
                                participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                showsBuild.toggle()
                            }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                        } else {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                            showsBuild.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                            Text("Remove")
                                .font(formatter.font())
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(formatter.color(.primaryFG))
                        .background(formatter.color(.highContrastWhite))
                        .cornerRadius(10)
                    }
                    
                    if let uid = profileVM.myUID {
                        if team.id != uid {
                            Button {
                                if !participantsVM.savedTeams.contains(team) {
                                    participantsVM.writeTeamToFirestore(team: team)
                                } else {
                                    formatter.setAlertSettings(alertAction: {
                                        participantsVM.removeTeamFromFirestore(id: team.id)
                                    }, alertTitle: "Delete Player?", alertSubtitle: "If you delete \(team.name), you'll have to add them back later manually.", hasCancel: true, actionLabel: "Delete")
                                }
                            } label: {
                                HStack {
                                    Image(systemName: participantsVM.savedTeams.contains(team) ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                                        .font(.system(size: 20, weight: .bold))
                                        .offset(y: -3)
                                    Text(participantsVM.savedTeams.contains(team) ? "Unsave" : "Save")
                                        .font(formatter.font())
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundColor(formatter.color(.primaryFG))
                                .background(formatter.color(.highContrastWhite))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .frame(height: 60)
                HStack {
                    TextField("Edit Score", text: $scoreToAdd)
                        .keyboardType(.numberPad)
                    Button(action: {
                        if !scoreToAdd.isEmpty {
                            formatter.hapticFeedback(style: .soft)
                            participantsVM.editScore(index: self.team.index, amount: Int(scoreToAdd) ?? 0)
                            scoreToAdd.removeAll()
                        }
                    }, label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(formatter.color(scoreToAdd.isEmpty ? .lowContrastWhite : .highContrastWhite))
                    })
                }
                .font(formatter.font())
                .padding()
                .background(formatter.color(.secondaryFG))
                .cornerRadius(10)
                .accentColor(formatter.color(.secondaryAccent))
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    dismissBuild()
                }, label: {
                    HStack {
                        Text("Done")
                            .font(formatter.font())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                })
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(formatter.color(.primaryFG))
            .cornerRadius(20)
            .padding()
            .offset(x: showsBuild ? 0 : -600)
        }
    }
    
    func dismissBuild() {
        if participantsVM.savedTeams.contains(team) {
            participantsVM.editTeamInDB(teamIndex: team.index)
        }
        formatter.resignKeyboard()
        showsBuild.toggle()
    }
}

struct MobileColorPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var teamColor: String
    
    @State var color: Color
    @State var colorString: String
    
    var isSettingsPicker = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .opacity(teamColor == colorString ? 1 : 0.2)
                .onTapGesture {
                    formatter.hapticFeedback(style: .rigid, intensity: .weak)
                    teamColor = colorString
                }
        }
        .frame(height: 20)
    }
}

