//
//  GameSettingsView.swift
//  Trivio!
//
//  Created by David Chen on 7/21/21.
//

import Foundation
import SwiftUI

struct GameSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        VStack (spacing: 0) {
            // Settings header
            GameSettingsHeaderView()
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .leading, spacing: 20) {
                    
                    // Contestants (quick add & preview)
                    GameSettingsContestantsView()
                        .padding(.top)
                    
                    // Selected game brief info
                    GameSettingsSelectedGameView()
                    
                    // Reading voice type
                    GameSettingsVoiceTypeView()
                    
                    // Reading voice speed
                    GameSettingsVoiceSpeedView()
                        .padding(.bottom, 30)
                }
                .padding([.horizontal], 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct GameSettingsHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var gameInProgress: Bool {
        if gamesVM.gamePhase == .trivio && gamesVM.usedAnswers.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        HStack (alignment: .bottom) {
            Text("Game Settings")
                .font(formatter.font(fontSize: .extraLarge))
            Spacer()
            Button(action: {
                if participantsVM.teams.count > 0 {
                    gamesVM.gameSetupMode = .play
                }
            }, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("\(gameInProgress ? "Resume Game" : "Start Game")")
                }
            })
            .font(formatter.font(fontSize: .mediumLarge))
            .foregroundColor(formatter.color(.primaryFG))
            .padding()
            .background(formatter.color(.highContrastWhite))
            .cornerRadius(5)
            .opacity(participantsVM.teams.count > 0 ? 1 : 0.5)
        }
        .padding([.horizontal], 30)
        .padding(.top, 50)
        .padding(.bottom, 20)
        .background(formatter.color(.primaryBG))
    }
}

struct GameSettingsContestantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var gameInProgress: Bool {
        if gamesVM.gamePhase == .trivio && gamesVM.usedAnswers.count == 0 {
            return false
        } else {
            return true
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                Text("Contestants")
                    .font(formatter.font(fontSize: .large))
                Button {
                    gamesVM.gameSetupMode = .participants
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 25, weight: .bold))
                }
                Spacer()
            }
            ScrollView (.horizontal) {
                HStack {
                    Text("Quick Add")
                        .font(formatter.font(fontSize: .mediumLarge))
                        .padding(.trailing, 15)
                    ForEach(participantsVM.historicalTeams) { team in
                        HStack {
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
                                participantsVM.addTeam(id: team.id, name: team.name, members: team.members, score: 0, color: team.color)
                            } else {
                                if gameInProgress {
                                    formatter.setAlertSettings(alertAction: {
                                        participantsVM.removeTeam(index: participantsVM.getIndexByID(id: team.id))
                                    }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
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
            .cornerRadius(10)
            
            HStack {
                ForEach(participantsVM.teams, id: \.self) { team in
                    HStack {
                        Circle()
                            .foregroundColor(ColorMap().getColor(color: team.color))
                            .frame(width: 20, height: 20)
                        Text(team.name)
                            .font(formatter.font(fontSize: .large))
                        Spacer()
                        Button {
                            if gameInProgress {
                                formatter.setAlertSettings(alertAction: {
                                    participantsVM.removeTeam(index: team.index)
                                }, alertTitle: "Remove \(team.name)?", alertSubtitle: "If you remove a contestant during a game, their score will not be saved.", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                            } else {
                                participantsVM.removeTeam(index: team.index)
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 30, weight: .bold))
                        }
                    }
                    .padding(30)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct GameSettingsSelectedGameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                Text("Selected Game")
                    .font(formatter.font(fontSize: .large))
                Button {
                    gamesVM.menuChoice = .explore
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 25, weight: .bold))
                }
                Spacer()
            }
            VStack (alignment: .leading, spacing: 10) {
                Text(gamesVM.title)
                    .font(formatter.font(fontSize: .mediumLarge))
                Text(gamesVM.queriedUserName.isEmpty ? "Trivio Official" : gamesVM.queriedUserName)
                    .font(formatter.font(.regular))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(.primaryFG))
            .cornerRadius(10)
        }
    }
}

struct GameSettingsVoiceTypeView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack (spacing: 15) {
                Text("Reading Voice Type")
                    .font(formatter.font(fontSize: .large))
                Button {
                    formatter.speaker.speak("This is the voice of your Trivio host!")
                } label: {
                    HStack {
                        Image(systemName: "speaker.3.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("Sample")
                            .font(formatter.font(fontSize: .small))
                    }
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            ScrollView (.horizontal) {
                HStack {
                    GameSettingsGenderPickerView(speechGender: .male, genderString: "Male", emphasisColor: emphasisColor)
                    GameSettingsGenderPickerView(speechGender: .female, genderString: "Female", emphasisColor: emphasisColor)
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 1, height: 30)
                        .padding(.horizontal)
                    GameSettingsLanguagePickerView(speechLanguage: .americanEnglish, languageString: "American English", emphasisColor: emphasisColor)
                    GameSettingsLanguagePickerView(speechLanguage: .britishEnglish, languageString: "British English", emphasisColor: emphasisColor)
                }
            }
            .padding()
            .background(formatter.color(emphasisColor))
            .cornerRadius(5)
        }
    }
}

struct GameSettingsVoiceSpeedView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack (spacing: 15) {
                Text("Reading Voice Speed")
                    .font(formatter.font(fontSize: .large))
                Button {
                    formatter.speaker.speak("This is a sample of my reading speed.")
                } label: {
                    HStack {
                        Image(systemName: "speaker.3.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("Sample")
                            .font(formatter.font(fontSize: .small))
                    }
                    .padding()
                    .background(formatter.color(.secondaryFG))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            ScrollView (.horizontal) {
                HStack {
                    GameSettingsSpeedPickerView(speechSpeed: .slow, speedString: "Slow", emphasisColor: emphasisColor)
                    GameSettingsSpeedPickerView(speechSpeed: .regular, speedString: "Regular", emphasisColor: emphasisColor)
                    GameSettingsSpeedPickerView(speechSpeed: .fast, speedString: "Fast", emphasisColor: emphasisColor)
                }
            }
            .padding()
            .background(formatter.color(emphasisColor))
            .cornerRadius(5)
        }
    }
}

struct GameSettingsGenderPickerView: View {
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

struct GameSettingsLanguagePickerView: View {
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

struct GameSettingsSpeedPickerView: View {
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
