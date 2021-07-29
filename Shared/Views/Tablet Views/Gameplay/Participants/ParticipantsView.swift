//
//  ParticipantsView.swift
//  Trivio
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI

struct ParticipantsView: View {
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
                ParticipantsHeaderView(showsBuild: $showsBuild, teamToEdit: $teamToEdit)
                
                // All saved players
                SavedPlayersView()
                
                // All active participants
                ActiveParticipantsView(showsBuild: $showsBuild, teamToEdit: $teamToEdit)
            }
            .padding([.horizontal, .top], 30)
            TeamBuildView(showsBuild: $showsBuild, team: participantsVM.teams.indices.contains(teamToEdit.index) ? $participantsVM.teams[teamToEdit.index] : $teamToEdit)
        }
    }
}

struct ParticipantsHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showsBuild: Bool
    @Binding var teamToEdit: Team
    
    var body: some View {
        HStack (spacing: formatter.shrink(iPadSize: 15)) {
            HStack {
                Text("\(participantsVM.isTeams ? "Teams" : "Contestants")")
                    .font(formatter.font(fontSize: .extraLarge))
                Button (action: {
                    participantsVM.addTeam(name: "", members: [], score: 0, color: "blue")
                    teamToEdit = participantsVM.teams.last!
                    showsBuild.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .padding(formatter.deviceType == .iPad ? 10 : 5)
                }
                Spacer()
            }
            Button(action: {
                participantsVM.isTeams.toggle()
            }, label: {
                Text("Switch to \(participantsVM.isTeams ? "Contestants" : "Teams")")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .foregroundColor(formatter.color(.primaryFG))
                    .padding(formatter.padding())
                    .background(formatter.color(.highContrastWhite))
                    .cornerRadius(formatter.cornerRadius(5))
            })
            Button(action: {
                gamesVM.gameSetupMode = .settings
            }, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("Play")
                }
            })
            .font(formatter.font(fontSize: .mediumLarge))
            .foregroundColor(formatter.color(.primaryFG))
            .padding(formatter.padding())
            .background(formatter.color(.highContrastWhite))
            .cornerRadius(formatter.cornerRadius(5))
        }
    }
}

struct SavedPlayersView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                Text("Saved Players")
                    .font(formatter.font(fontSize: .mediumLarge))
                    .padding(.horizontal, 15)
                ForEach(participantsVM.historicalTeams) { team in
                    HStack {
                        Circle()
                            .foregroundColor(ColorMap().getColor(color: team.color))
                            .frame(width: 10)
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
                        if !participantsVM.teams.contains(team) {
                            participantsVM.addTeam(id: team.id, name: team.name, members: team.members, score: 0, color: team.color)
                        } else {
                            participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
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

struct ActiveParticipantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var showsBuild: Bool
    @Binding var teamToEdit: Team
    
    var body: some View {
        HStack (alignment: .top, spacing: 15) {
            ForEach(participantsVM.teams) { team in
                VStack (spacing: 15) {
                    HStack (spacing: participantsVM.teams.count > 3 ? 7 : 15) {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(ColorMap().getColor(color: team.color))
                        Text(team.name.isEmpty ? "" : team.name + (participantsVM.isTeams ? " (\(team.members.count))" : ""))
                            .font(formatter.font(fontSize: participantsVM.teams.count > 3 ? .semiLarge : .large))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        Button(action: {
                            participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: participantsVM.teams.count > 3 ? 30 : 40, weight: .bold))
                                .minimumScaleFactor(0.5)
                        })
                    }
                    .padding(participantsVM.teams.count > 3 ? 20 : 30)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(20)
                    .onTapGesture {
                        teamToEdit = team
                        showsBuild.toggle()
                    }
                    
                    if participantsVM.isTeams {
                        ScrollView (.vertical, showsIndicators: false) {
                            VStack (spacing: 15) {
                                // Add member textfield
                                AddMemberTextFieldView(teamIndex: team.index)
                                
                                // Members Scrollview
                                ForEach(team.members, id: \.self) { member in
                                    HStack {
                                        Text(member)
                                            .font(formatter.font(fontSize: .large))
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                        Spacer()
                                        Button(action: {
                                            participantsVM.removeMember(index: team.index, name: member)
                                        }, label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(formatter.color(.highContrastWhite))
                                        })
                                    }
                                    .padding(30)
                                    .frame(maxWidth: .infinity)
                                    .background(formatter.color(.secondaryFG))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    } else {
                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

struct AddMemberTextFieldView: View {
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
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(formatter.color(newMemberName.isEmpty ? .lowContrastWhite : .highContrastWhite))
            })
        }
        .padding(30)
        .background(formatter.color(.primaryFG))
        .accentColor(formatter.color(.secondaryAccent))
        .cornerRadius(10)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.size.width
            let h = rect.size.height

            let tr = min(min(self.tr, h/2), w/2)
            let tl = min(min(self.tl, h/2), w/2)
            let bl = min(min(self.bl, h/2), w/2)
            let br = min(min(self.br, h/2), w/2)

            path.move(to: CGPoint(x: w / 2.0, y: 0))
            path.addLine(to: CGPoint(x: w - tr, y: 0))
            path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: h - br))
            path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: bl, y: h))
            path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: tl))
            path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        }
    }
}
