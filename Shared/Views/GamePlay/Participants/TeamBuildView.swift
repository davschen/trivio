//
//  TeamBuildView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/19/21.
//

import Foundation
import SwiftUI

struct TeamBuildView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showsBuild: Bool
    @Binding var team: Team
    
    @State var nameToAdd = ""
    @State var scoreToAdd = ""
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(self.showsBuild ? 0.9 : 0)
                .onTapGesture {
                    self.showsBuild.toggle()
                    formatter.resignKeyboard()
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
                    ColorPickerView(color: formatter.color(.blue), colorString: "blue", team: $team)
                    ColorPickerView(color: formatter.color(.purple), colorString: "purple", team: $team)
                    ColorPickerView(color: formatter.color(.green), colorString: "pink", team: $team)
                    ColorPickerView(color: formatter.color(.yellow), colorString: "yellow", team: $team)
                    ColorPickerView(color: formatter.color(.orange), colorString: "orange", team: $team)
                    ColorPickerView(color: formatter.color(.red), colorString: "red", team: $team)
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
                    Button {
                        if !participantsVM.historicalTeams.contains(team) {
                            participantsVM.writeTeamToFirestore(team: team)
                        } else {
                            formatter.setAlertSettings(alertAction: {
                                participantsVM.removeTeamFromFirestore(id: team.id)
                            }, alertTitle: "Delete Player?", alertSubtitle: "If you delete \(team.name), you'll have to add them back later manually.", hasCancel: true, actionLabel: "Delete")
                        }
                    } label: {
                        HStack {
                            Image(systemName: participantsVM.historicalTeams.contains(team) ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                                .font(.system(size: 20, weight: .bold))
                                .offset(y: -3)
                            Text(participantsVM.historicalTeams.contains(team) ? "Unsave" : "Save")
                                .font(formatter.font())
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(formatter.color(.primaryFG))
                        .background(formatter.color(.highContrastWhite))
                        .cornerRadius(10)
                    }
                }
                .frame(height: 60)
                HStack {
                    TextField("Edit Score", text: $scoreToAdd)
                        .keyboardType(.numberPad)
                    Button(action: {
                        if !self.scoreToAdd.isEmpty {
                            self.participantsVM.editScore(index: self.team.index, amount: Int(scoreToAdd) ?? 0)
                            self.scoreToAdd = ""
                        }
                    }, label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(formatter.color(.highContrastWhite))
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
    @State var color: Color
    @State var colorString: String
    @Binding var team: Team
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    self.team.color = colorString
                    self.participantsVM.editColor(index: team.index, color: colorString)
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
