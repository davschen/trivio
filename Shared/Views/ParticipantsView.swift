//
//  ParticipantsView.swift
//  Trivio
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI

struct ParticipantsView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @State var showsBuild = false
    @State var teamToEdit = Team(index: 0, name: "", members: [], score: 0, color: "")
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack (spacing: formatter.shrink(iPadSize: 15)) {
                    Text("\(participantsVM.isTeams ? "Teams" : "Contestants") (\(participantsVM.teams.count))")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                    Button (action: {
                        self.participantsVM.addTeam(name: "", members: [], score: 0, color: "")
                        self.teamToEdit = self.participantsVM.teams.last!
                        self.showsBuild.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(formatter.deviceType == .iPad ? .title : .title3)
                            .foregroundColor(Color("MainBG"))
                            .padding(formatter.deviceType == .iPad ? 10 : 5)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: {
                        participantsVM.isTeams.toggle()
                    }, label: {
                        Text("Switch to \(participantsVM.isTeams ? "Contestants" : "Teams")")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .foregroundColor(Color("MainAccent"))
                            .padding(formatter.padding())
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(formatter.cornerRadius(5))
                    })
                    Button(action: {
                        gamesVM.menuChoice = .game
                    }, label: {
                        HStack {
                            Image(systemName: "gamecontroller")
                            Text("Play")
                        }
                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    })
                    .padding(formatter.padding())
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(formatter.cornerRadius(5))
                }
                VStack (alignment: .leading, spacing: 0) {
                    Text("Who's Playing?")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                    ScrollView (.horizontal) {
                        HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                            ForEach(self.participantsVM.historicalTeams) { team in
                                HStack {
                                    Circle()
                                        .foregroundColor(ColorMap().getColor(color: team.color))
                                        .frame(width: 10)
                                    Text(team.name)
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                        .foregroundColor(self.participantsVM.teams.contains(team) ? .white : Color("MainAccent"))
                                }
                                .padding(formatter.padding())
                                .frame(height: formatter.shrink(iPadSize: 50, factor: 1.5))
                                .background(Color.gray.opacity(self.participantsVM.teams.contains(team) ? 1 : 0.4))
                                .cornerRadius(formatter.deviceType == .iPad ? 5 : 2)
                                .onTapGesture {
                                    if !self.participantsVM.teams.contains(team) {
                                        self.participantsVM.addTeam(id: team.id, name: team.name, members: team.members, score: 0, color: team.color)
                                    } else {
                                        self.participantsVM.removeTeam(index: self.participantsVM.getIndexByID(id: team.id))
                                    }
                                }
                                .onLongPressGesture {
                                    self.participantsVM.removeTeamFromFirestore(id: team.id)
                                }
                            }
                        }
                    }
                    Text("Press and hold a \(participantsVM.isTeams ? "team" : "contestant") to delete")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                }
                .opacity(participantsVM.historicalTeams.isEmpty ? 0 : 1)
                HStack (alignment: .top, spacing: formatter.deviceType == .iPad ? nil : 3) {
                    ForEach(self.participantsVM.teams) { team in
                        VStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                            ZStack {
                                Text(team.name.isEmpty ? "" : team.name + (self.participantsVM.isTeams ? " (\(team.members.count))" : ""))
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                    .foregroundColor(.white)
                                VStack {
                                    HStack {
                                        Image(systemName: self.participantsVM.historicalTeams.contains(team) ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                                            .font(formatter.deviceType == .iPad ? .title3 : .caption)
                                            .padding(5)
                                            .foregroundColor(Color("Darkened"))
                                            .onTapGesture {
                                                self.participantsVM.writeTeamToFirestore(team: team)
                                            }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                            .padding(formatter.padding())
                            .frame(maxWidth: .infinity)
                            .frame(height: formatter.shrink(iPadSize: 100, factor: 2))
                            .background(ColorMap().getColor(color: team.color))
                            .cornerRadius(formatter.cornerRadius(5))
                            .onTapGesture {
                                self.teamToEdit = team
                                self.showsBuild.toggle()
                            }
                            ScrollView (.vertical, showsIndicators: false) {
                                VStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                                    ForEach(team.members, id: \.self) { member in
                                        HStack {
                                            Text(member)
                                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                            Spacer()
                                            Image(systemName: "minus.circle.fill")
                                                .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                                                .foregroundColor(Color("MainFG"))
                                                .onTapGesture {
                                                    self.participantsVM.removeMember(index: team.index, name: member)
                                                }
                                        }
                                        .padding(formatter.padding())
                                        .frame(maxWidth: .infinity)
                                        .background(Color("MainAccent"))
                                        .cornerRadius(formatter.cornerRadius(5))
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }
            }
            TeamBuildView(showsBuild: $showsBuild, team: self.participantsVM.teams.count > teamToEdit.index ? $participantsVM.teams[self.teamToEdit.index] : $teamToEdit, isTeams: $participantsVM.isTeams)
        }
    }
}

struct TeamBuildView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showsBuild: Bool
    @Binding var team: Team
    @Binding var isTeams: Bool
    
    @State var nameToAdd = ""
    @State var scoreToAdd = ""
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
                .opacity(self.showsBuild ? 0.5 : 0)
                .onTapGesture {
                    self.showsBuild.toggle()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            VStack {
                Spacer()
                ZStack (alignment: .top) {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                    VStack {
                        ScrollView (.vertical, showsIndicators: false) {
                            VStack (alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Editing: \(self.team.name)")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 40))
                                    Image(systemName: "minus.circle.fill")
                                        .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                                        .foregroundColor(.white)
                                        .background(Color("MainFG"))
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            self.showsBuild.toggle()
                                            self.participantsVM.removeTeam(index: team.index)
                                        }
                                }
                                HStack {
                                    ColorPickerView(color: .orange, colorString: "orange", team: $team)
                                    ColorPickerView(color: .yellow, colorString: "yellow", team: $team)
                                    ColorPickerView(color: .purple, colorString: "purple", team: $team)
                                    ColorPickerView(color: .red, colorString: "red", team: $team)
                                    ColorPickerView(color: .pink, colorString: "pink", team: $team)
                                    ColorPickerView(color: .blue, colorString: "blue", team: $team)
                                }
                                .frame(height: formatter.shrink(iPadSize: 50, factor: 2))
                                .padding(.horizontal, 5)
                                HStack {
                                    VStack (alignment: .leading, spacing: 0) {
                                        Text("\(self.isTeams ? "Team" : "Participant") Name")
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                                        HStack {
                                            TextField("Add Name", text: $team.name)
                                                .padding(formatter.padding())
                                                .background(Color.white.opacity(0.5))
                                                .cornerRadius(5)
                                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                                .accentColor(.white)
                                            Spacer()
                                        }
                                    }
                                    if self.isTeams {
                                        Spacer(minLength: 20)
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("Add Member Name")
                                                .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                                            HStack {
                                                TextField("Add Member Name", text: $nameToAdd)
                                                    .padding(formatter.padding())
                                                    .background(Color.white.opacity(0.5))
                                                    .cornerRadius(5)
                                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                                    .accentColor(.white)
                                                Button {
                                                    if !self.nameToAdd.isEmpty {
                                                        self.participantsVM.addMember(index: team.index, name: nameToAdd)
                                                        self.nameToAdd = ""
                                                    }
                                                } label: {
                                                    Image(systemName: "plus")
                                                        .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                                                        .foregroundColor(Color("MainBG"))
                                                        .padding(formatter.padding(size: 10))
                                                        .background(Color.white)
                                                        .clipShape(Circle())
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                .accentColor(.black)
                                VStack (alignment: .leading, spacing: 0) {
                                    Text("Edit Score (\(team.score))")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                                    HStack {
                                        TextField("Score to Add", text: $scoreToAdd)
                                            .padding(formatter.padding())
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(5)
                                            .keyboardType(.numberPad)
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            .accentColor(.white)
                                        Button(action: {
                                            if !self.scoreToAdd.isEmpty {
                                                self.participantsVM.editScore(index: self.team.index, amount: Int(scoreToAdd) ?? 0)
                                                self.scoreToAdd = ""
                                            }
                                        }, label: {
                                            Image(systemName: "checkmark")
                                                .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                                                .foregroundColor(Color("MainBG"))
                                                .padding(formatter.padding(size: 10))
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        })
                                        Spacer()
                                    }
                                }
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.showsBuild.toggle()
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }, label: {
                                        Text("Finished")
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            .foregroundColor(Color.white)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                                            .padding(formatter.padding())
                                            .background(Color.gray)
                                            .cornerRadius(5.0)
                                            .padding(.vertical, formatter.padding())
                                    })
                                }
                            }
                            .padding(formatter.padding(size: 40))
                        }
                        .resignKeyboardOnDragGesture()
                    }
                }
                .frame(height: formatter.deviceType == .iPad ? UIScreen.main.bounds.height * 0.5 : nil)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: self.showsBuild ? 0 : UIScreen.main.bounds.height)
                .keyboardAware()
            }
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
        VStack {
            RoundedRectangle(cornerRadius: 5).foregroundColor(color)
                .background(RoundedRectangle(cornerRadius: 5).stroke(
                                Color.blue,
                                lineWidth: team.color == colorString ? formatter.shrink(iPadSize: 10, factor: 2) : 0)
                )
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    self.team.color = colorString
                    self.participantsVM.editColor(index: team.index, color: colorString)
                }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct ColorMap {
    func getColor(color: String) -> Color {
        switch color {
        case "orange":
            return Color.orange
        case "yellow":
            return Color.yellow
        case "purple":
            return Color.purple
        case "red":
            return Color.red
        case "pink":
            return Color.pink
        default:
            return Color.blue
        }
    }
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
