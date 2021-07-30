//
//  MobileGameSettingsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileGameSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var showsBuild = false
    @State var teamToEdit = Empty().team
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                // Settings header
                MobileGameSettingsHeaderView()
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 20) {
                        
                        // Contestants (quick add & preview)
                        MobileGameSettingsContestantsView(showsBuild: $showsBuild, teamToEdit: $teamToEdit)
                            .padding(.top)
                        
                        // Selected game brief info
                        MobileGameSettingsSelectedGameView()
                        
                        // Reading voice type
                        MobileGameSettingsVoiceTypeView()
                        
                        // Reading voice speed
                        MobileGameSettingsVoiceSpeedView()
                            .padding(.bottom, 20)
                    }
                    .padding([.horizontal])
                }
            }
            MobileTeamBuildView(showsBuild: $showsBuild, team: participantsVM.teams.indices.contains(teamToEdit.index) ? $participantsVM.teams[teamToEdit.index] : $teamToEdit)
        }
    }
}

struct MobileGameSettingsHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var gameIsPlayable: Bool {
        return participantsVM.teams.count > 0 && !gamesVM.selectedEpisode.isEmpty
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Game Settings")
                .font(formatter.font(fontSize: .extraLarge))
            Button(action: {
                if gameIsPlayable {
                    gamesVM.gameSetupMode = .play
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                }
            }, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("\(gamesVM.gameInProgress() ? "Resume Game" : "Start Game")")
                }
                .font(formatter.font(fontSize: .mediumLarge))
                .foregroundColor(formatter.color(.primaryFG))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.highContrastWhite))
                .cornerRadius(5)
                .opacity(gameIsPlayable ? 1 : 0.5)
            })
        }
        .padding()
        .background(formatter.color(.primaryBG))
    }
}

struct MobileGameSettingsContestantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showsBuild: Bool
    @Binding var teamToEdit: Team
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Button {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                gamesVM.gameSetupMode = .participants
            } label: {
                HStack {
                    Text("Contestants")
                        .font(formatter.font(fontSize: .mediumLarge))
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                }
            }
            VStack (alignment: .leading, spacing: 5) {
                Text("Quick Add")
                    .font(formatter.font())
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(participantsVM.historicalTeams) { team in
                            HStack (spacing: 3) {
                                Circle()
                                    .foregroundColor(ColorMap().getColor(color: team.color))
                                    .frame(width: 10, height: 10)
                                Text(team.name)
                                    .font(formatter.font())
                                    .foregroundColor(formatter.color(.highContrastWhite))
                            }
                            .padding()
                            .frame(height: 50)
                            .background(formatter.color(participantsVM.teams.contains(team) ? .primaryAccent : .secondaryFG))
                            .cornerRadius(5)
                            .onTapGesture {
                                if !participantsVM.teams.contains(team) {
                                    formatter.hapticFeedback(style: .soft)
                                    participantsVM.addTeam(id: team.id, name: team.name, members: team.members, score: 0, color: team.color)
                                } else {
                                    if gamesVM.gameInProgress() {
                                        formatter.setAlertSettings(alertAction: {
                                            formatter.hapticFeedback(style: .soft)
                                            participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                        }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                                    } else {
                                        formatter.hapticFeedback(style: .soft, intensity: .weak)
                                        participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(10)
            .background(formatter.color(.primaryFG))
            .cornerRadius(5)
            
            HStack (spacing: 5) {
                ForEach(participantsVM.teams, id: \.self) { team in
                    HStack (spacing: 3) {
                        Circle()
                            .foregroundColor(ColorMap().getColor(color: team.color))
                            .frame(width: 10, height: 10)
                        Text(team.name)
                            .lineLimit(1)
                            .font(formatter.font(fontSize: participantsVM.teams.count > 2 ? .regular : .mediumLarge))
                            .minimumScaleFactor(0.3)
                        Spacer(minLength: 0)
                        Button {
                            if gamesVM.gameInProgress() {
                                formatter.setAlertSettings(alertAction: {
                                    formatter.hapticFeedback(style: .rigid, intensity: .strong)
                                    participantsVM.removeTeam(index: team.index)
                                }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                            } else {
                                formatter.hapticFeedback(style: .rigid, intensity: .strong)
                                participantsVM.removeTeam(index: team.index)
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(formatter.iconFont(participantsVM.teams.count > 2 ? .small : .medium))
                        }
                    }
                    .padding(participantsVM.teams.count > 2 ? 7 : 15)
                    .frame(height: 60)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        formatter.hapticFeedback(style: .medium)
                        teamToEdit = team
                        showsBuild.toggle()
                    }
                }
            }
        }
    }
}

struct MobileGameSettingsSelectedGameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Button {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                gamesVM.menuChoice = .explore
            } label: {
                HStack {
                    Text("Selected Game")
                        .font(formatter.font(fontSize: .mediumLarge))
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                }
            }
            if !gamesVM.selectedEpisode.isEmpty {
                VStack (alignment: .leading, spacing: 5) {
                    Text(gamesVM.title)
                        .font(formatter.font(fontSize: .mediumLarge))
                    Text(gamesVM.queriedUserName.isEmpty ? "Trivio Official" : gamesVM.queriedUserName)
                        .font(formatter.font(.regular))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(formatter.color(.primaryFG))
                .cornerRadius(5)
            } else {
                VStack (spacing: 10) {
                    Text("No game selected")
                        .font(formatter.font(.regularItalic, fontSize: .medium))
                    Button {
                        formatter.hapticFeedback(style: .light)
                        gamesVM.menuChoice = .explore
                    } label: {
                        Text("Pick a game")
                            .font(formatter.font(fontSize: .medium))
                            .foregroundColor(formatter.color(.primaryFG))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(formatter.color(.highContrastWhite))
                            .cornerRadius(5)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(formatter.color(.primaryFG))
                .cornerRadius(5)
            }
        }
    }
}

struct MobileGameSettingsVoiceTypeView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack (spacing: 15) {
                Text("Reading Voice Type")
                    .font(formatter.font(fontSize: .mediumLarge))
                Button {
                    formatter.speaker.speak("This is the voice of your Trivio host!")
                } label: {
                    HStack {
                        Image(systemName: "speaker.3.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Sample")
                            .font(formatter.font(fontSize: .small))
                    }
                    .padding(10)
                    .background(formatter.color(.secondaryFG))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    GameSettingsGenderPickerView(speechGender: .male, genderString: "Male", emphasisColor: emphasisColor)
                    GameSettingsGenderPickerView(speechGender: .female, genderString: "Female", emphasisColor: emphasisColor)
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 30)
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    GameSettingsLanguagePickerView(speechLanguage: .americanEnglish, languageString: "American English", emphasisColor: emphasisColor)
                    GameSettingsLanguagePickerView(speechLanguage: .britishEnglish, languageString: "British English", emphasisColor: emphasisColor)
                }
            }
            .padding(10)
            .background(formatter.color(emphasisColor))
            .cornerRadius(5)
        }
    }
}

struct MobileGameSettingsVoiceSpeedView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack (spacing: 15) {
                Text("Reading Speed")
                    .font(formatter.font(fontSize: .mediumLarge))
                Button {
                    formatter.speaker.speak("This is a sample of my reading speed.")
                } label: {
                    HStack {
                        Image(systemName: "speaker.3.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Sample")
                            .font(formatter.font(fontSize: .small))
                    }
                    .padding(10)
                    .background(formatter.color(.secondaryFG))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    GameSettingsSpeedPickerView(speechSpeed: .slow, speedString: "Slow", emphasisColor: emphasisColor)
                    GameSettingsSpeedPickerView(speechSpeed: .regular, speedString: "Regular", emphasisColor: emphasisColor)
                    GameSettingsSpeedPickerView(speechSpeed: .fast, speedString: "Fast", emphasisColor: emphasisColor)
                }
            }
            .padding(10)
            .background(formatter.color(emphasisColor))
            .cornerRadius(5)
        }
    }
}

struct MobileGameSettingsGenderPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var selectedGender: SpeechGender = SpeechGender(rawValue: UserDefaults.standard.string(forKey: "speechGender") ?? "male") ?? .male
    
    let speechGender: SpeechGender
    let genderString: String
    let defaults = UserDefaults.standard
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "largecircle.fill.circle")
                    .font(.system(size: 20, weight: .bold))
                Text(genderString)
                    .font(formatter.font(fontSize: .mediumLarge))
            }
            .padding()
            .background(formatter.color(selectedGender == speechGender ? .primaryAccent : emphasisColor))
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                UserDefaults.standard.set(speechGender.rawValue, forKey: "speechGender")
                NotificationCenter.default.post(name: NSNotification.Name("SpeechGenderChange"), object: nil)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("SpeechGenderChange"), object: nil, queue: .main) { (_) in
                    let selectedGender = SpeechGender(rawValue: UserDefaults.standard.string(forKey: "speechGender") ?? "male") ?? .male
                    self.selectedGender = selectedGender
                }
            }
        }
    }
}

struct MobileGameSettingsLanguagePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var selectedLanguage: SpeechLanguage = SpeechLanguage(rawValue: UserDefaults.standard.string(forKey: "speechLanguage") ?? "britishEnglish") ?? .britishEnglish
    
    let speechLanguage: SpeechLanguage
    let languageString: String
    let defaults = UserDefaults.standard
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "largecircle.fill.circle")
                    .font(.system(size: 20, weight: .bold))
                Text(languageString)
                    .font(formatter.font(fontSize: .mediumLarge))
            }
            .padding()
            .background(formatter.color(selectedLanguage == speechLanguage ? .primaryAccent : emphasisColor))
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                UserDefaults.standard.set(speechLanguage.rawValue, forKey: "speechLanguage")
                NotificationCenter.default.post(name: NSNotification.Name("SpeechLanguageChange"), object: nil)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("SpeechLanguageChange"), object: nil, queue: .main) { (_) in
                    let selectedLanguage = SpeechLanguage(rawValue: UserDefaults.standard.string(forKey: "speechLanguage") ?? "britishEnglish") ?? .britishEnglish
                    self.selectedLanguage = selectedLanguage
                }
            }
        }
    }
}

struct MobileGameSettingsSpeedPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var selectedSpeed: Float = UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5
    
    let speechSpeed: SpeechSpeed
    let speedString: String
    let defaults = UserDefaults.standard
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "largecircle.fill.circle")
                    .font(.system(size: 20, weight: .bold))
                Text(speedString)
                    .font(formatter.font(fontSize: .mediumLarge))
            }
            .padding()
            .background(formatter.color(selectedSpeed == speechSpeed.rawValue ? .primaryAccent : emphasisColor))
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .rigid, intensity: .weak)
                UserDefaults.standard.set(speechSpeed.rawValue, forKey: "speechSpeed")
                NotificationCenter.default.post(name: NSNotification.Name("SpeechSpeedChange"), object: nil)
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("SpeechSpeedChange"), object: nil, queue: .main) { (_) in
                let selectedSpeed = UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5
                self.selectedSpeed = selectedSpeed
            }
        }
    }
}

