//
//  TeamBuildView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/19/21.
//

import Foundation
import SwiftUI

struct TeamBuildView: View {
    @EnvironmentObject var formatter: MasterHandler
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
                    if participantsVM.savedTeams.contains(team) {
                        participantsVM.editTeamInDB(teamIndex: team.index)
                    }
                    formatter.resignKeyboard()
                    showsBuild.toggle()
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
                HStack {
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
                        showsBuild.toggle()
                        participantsVM.removeTeam(index: team.index)
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
                            participantsVM.editScore(index: self.team.index, pointValueInt: Int(scoreToAdd) ?? 0)
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
                .keyboardAware()
            }
            .padding(20)
            .frame(width: 450)
            .background(formatter.color(.primaryFG))
            .cornerRadius(20)
            .padding(30)
            .offset(x: showsBuild ? 0 : -600)
        }
    }
}

struct ColorPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var team: Team
    
    @State var color: Color
    @State var colorString: String
    
    var isSettingsPicker = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    team.color = colorString
                    participantsVM.editColor(index: team.index, color: colorString)
                    if isSettingsPicker {
                        participantsVM.editTeamInDB(team: team)
                    }
                }
            if team.color == colorString || (team.color.isEmpty && colorString == "blue") {
                Circle()
                    .frame(width: 15, height: 15)
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .transition(.scale)
            }
        }
        .frame(height: 50)
    }
}
