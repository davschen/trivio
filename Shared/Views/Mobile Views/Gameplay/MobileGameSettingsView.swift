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
    
    @State var isPresentingGameView = false
    @State var isPresentingTrivioLiveView = false
    
    init() {
        Theme.navigationBarColors(
            background: UIColor(MasterHandler().color(.primaryFG)),
            titleColor: UIColor(MasterHandler().color(.highContrastWhite))
        )
    }
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            ZStack (alignment: .bottom) {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 20) {
                        // Settings header
                        MobileGameSettingsHeaderView()
                            .padding([.top, .horizontal])
                        
                        MobileGameSettingsCategoryPreviewView()
                        
                        // Contestants View
                        MobileGameSettingsContestantsView()
                        
                        // Game Settings
                        MobileGameSettingsCardView()
                            .padding(.bottom, 45)
                    }
                }
                .padding(.bottom)
                
                MobileGameSettingsFooterView(isPresentingGameView: $isPresentingGameView, isPresentingTrivioLiveView: $isPresentingTrivioLiveView)
                    .padding(.top, 5)
            }
            
            NavigationLink(isActive: $isPresentingGameView, destination: {
                MobileGameplayView()
            }, label: { EmptyView() })
            .isDetailLink(false)
            .hidden()
            
            NavigationLink(isActive: $isPresentingTrivioLiveView, destination: {
                MobileTrivioLivePreviewView()
            }, label: { EmptyView() })
            .isDetailLink(false)
            .hidden()
        }
        .withBackButton()
    }
}

struct MobileGameSettingsHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("\(gamesVM.customSet.title)")
                .font(formatter.font(fontSize: .large))
            Text("Created by \(exploreVM.getUsernameFromUserID(userID: gamesVM.customSet.userID)) on \(gamesVM.dateFormatter.string(from: gamesVM.customSet.dateCreated))")
                .font(formatter.font(.regular, fontSize: .regular))
            // TODO: Space for an optional description
        }
    }
}

struct MobileGameSettingsCategoryPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel

    var body: some View {
        VStack (alignment: .leading, spacing: 3) {
            HStack {
                Text("Round 1")
                Text("(\(gamesVM.tidyCustomSet.round1Cats.count) categories)")
                    .font(formatter.font(.regularItalic, fontSize: .regular))
            }
            .padding(.horizontal)
            MobileGamePreviewView(categories: gamesVM.tidyCustomSet.round1Cats)
                .padding(.bottom, 5)
            
            HStack {
                Text("Round 2")
                Text("(\(gamesVM.tidyCustomSet.round2Cats.count) categories)")
                    .font(formatter.font(.regularItalic, fontSize: .regular))
            }
            .padding(.horizontal)
            MobileGamePreviewView(categories: gamesVM.tidyCustomSet.round2Cats)
        }
    }
}

struct MobileGameSettingsContestantsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var editingName = ""
    @State var editingColor = ""
    @State var editingID: String? = nil
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            HStack {
                Text("Contestants")
                    .font(formatter.font(fontSize: .mediumLarge))
                Button {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    participantsVM.teamToEdit = Empty().team
                    participantsVM.teamToEdit.index = participantsVM.savedTeams.count
                    
                    participantsVM.savedTeams.append(participantsVM.teamToEdit)
                    editingID = participantsVM.teamToEdit.id
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
                Spacer()
            }
            .padding(.bottom, 7).padding(.horizontal)
            
            VStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding(.leading)
                ForEach(participantsVM.savedTeams) { team in
                    VStack (alignment: .leading) {
                        MobileContestantsCellView(editingID: $editingID, editingName: $editingName, editingColor: $editingColor, team: team)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if team.id == editingID { return }
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
                        
                        MobileEditContestantsCellView(editingID: $editingID, editingName: $editingName, editingColor: $editingColor, team: team)
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                            .padding(.leading)
                    }
                }
            }
        }
    }
}

struct MobileContestantsCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var editingID: String?
    @Binding var editingName: String
    @Binding var editingColor: String
    
    let team: Team
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: participantsVM.teams.contains(team) ? "circle.inset.filled" : "circle")
                HStack (spacing: 4) {
                    Circle()
                        .foregroundColor(ColorMap().getColor(color: team.color))
                        .frame(width: 5, height: 5)
                    Text(team.name)
                        .font(formatter.font(participantsVM.teams.contains(team) ? .bold : .regular))
                    if profileVM.myUID == team.id {
                        Text("(me)")
                            .font(formatter.font(.regularItalic)) 
                    }
                }
            }
            .opacity(team.id == editingID ? 0.4 : 1)
            Spacer()
            Button {
                if editingID == team.id {
                    // "Done"
                    participantsVM.teamToEdit.id = editingID!
                    participantsVM.teamToEdit.name = editingName
                    participantsVM.teamToEdit.color = editingColor
                    participantsVM.editTeamInDB(team: participantsVM.teamToEdit)
                    
                    editingID = nil
                    participantsVM.teamToEdit = Empty().team
                } else {
                    // "Edit"
                    editingID = team.id
                    editingName = team.name
                    editingColor = team.color
                    editingID = team.id
                }
                
            } label: {
                Text(editingID == team.id ? "Done" : "Edit")
                    .font(formatter.font(.regular))
            }
        }
        .frame(height: 25)
        .foregroundColor(formatter.color(participantsVM.teams.contains(team) ? .secondaryAccent : .highContrastWhite))
        .padding(.horizontal)
    }
}

struct MobileEditContestantsCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var editingID: String?
    @Binding var editingName: String
    @Binding var editingColor: String
    
    let team: Team
    
    var body: some View {
        if editingID == team.id {
            HStack (alignment: .bottom) {
                VStack (alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(formatter.font(.bold, fontSize: .micro))
                    TextField("Aa", text: $editingName)
                        .font(formatter.font(.regular, fontSize: .medium))
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                
                VStack (alignment: .leading, spacing: 2) {
                    Text("Color")
                        .font(formatter.font(.bold, fontSize: .micro))
                    HStack (spacing: 2) {
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.blue), colorString: "blue")
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.purple), colorString: "purple")
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.green), colorString: "green")
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.yellow), colorString: "yellow")
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.orange), colorString: "orange")
                        MobileColorPickerView(teamColor: $editingColor, color: formatter.color(.red), colorString: "red")
                    }
                }
                .frame(width: 150)
                
                Button {
                    formatter.setAlertSettings(alertAction: {
                        formatter.hapticFeedback(style: .soft)
                        participantsVM.removeTeamFromFirestore(id: team.id)
                    }, alertTitle: "Delete \(team.name)?", alertSubtitle: "You cannot undo this action", hasCancel: true, actionLabel: "Yes, remove \(team.name)")
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .frame(width: 30, height: 30)
                        .foregroundColor(formatter.color(.red))
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(2)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Mobile Game Settings

struct MobileGameSettingsCardView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var editingSettingName = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("Game Settings")
                .font(formatter.font(.bold, fontSize: .mediumLarge))
                .padding(.horizontal).padding(.bottom, 10)
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(formatter.color(.lowContrastWhite))
            MobileGameSettingsClueAppearanceView()
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(formatter.color(.lowContrastWhite))
            MobileGameSettingsVoiceTypeView()
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(formatter.color(.lowContrastWhite))
            MobileGameSettingsVoiceSpeedView()
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(formatter.color(.lowContrastWhite))
            MobileGameSettingsGenderView()
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .foregroundColor(formatter.color(.lowContrastWhite))
        }
        .padding(.vertical)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(5)
        .padding(.horizontal).padding(.bottom, 20)
    }
}

struct MobileGameSettingsClueAppearanceView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var showingEditView = false
    @State var currentSelection: String = "Classic"
    
    var body: some View {
        VStack {
            HStack {
                Text("Clue Appearance")
                Spacer()
                HStack (spacing: 5) {
                    Text("\(currentSelection)")
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: showingEditView ? 180 : 0))
                }
                .font(formatter.font(.regular))
                .foregroundColor(formatter.color(.lowContrastWhite))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingEditView.toggle()
            }
            
            if showingEditView {
                HStack (spacing: 7) {
                    Spacer()
                    Text("Classic")
                        .font(formatter.font(.regular, fontSize: .regular))
                        .padding(7)
                        .frame(width: 80)
                        .foregroundColor(formatter.color(currentSelection == "Classic" ? .primaryFG : .highContrastWhite))
                        .background(formatter.color(currentSelection == "Classic" ? .highContrastWhite : .primaryFG))
                        .clipShape(Capsule())
                        .onTapGesture {
                            currentSelection = "Classic"
                        }
                    Text("Modern")
                        .font(formatter.font(.regular, fontSize: .regular))
                        .padding(7)
                        .frame(width: 80)
                        .foregroundColor(formatter.color(currentSelection == "Modern" ? .primaryFG : .highContrastWhite))
                        .background(formatter.color(currentSelection == "Modern" ? .highContrastWhite : .primaryFG))
                        .clipShape(Capsule())
                        .onTapGesture {
                            currentSelection = "Modern"
                        }
                }
            }
        }
        .padding()
    }
}

struct MobileGameSettingsVoiceTypeView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var showingEditView = false
    @State var selectedLanguage: SpeechLanguage = SpeechLanguage(rawValue: UserDefaults.standard.string(forKey: "speechLanguage") ?? "americanEnglish") ?? .britishEnglish
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        VStack {
            HStack {
                Text("Reading Voice")
                Spacer()
                HStack (spacing: 5) {
                    Text("\(selectedLanguage == .americanEnglish ? "American" : "British") English")
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: showingEditView ? 180 : 0))
                }
                .font(formatter.font(.regular))
                .foregroundColor(formatter.color(.lowContrastWhite))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingEditView.toggle()
            }
            if showingEditView {
                HStack (spacing: 7) {
                    Spacer()
                    MobileGameSettingsLanguagePickerView(selectedLanguage: $selectedLanguage, speechLanguage: .americanEnglish, languageString: "American English")
                    MobileGameSettingsLanguagePickerView(selectedLanguage: $selectedLanguage, speechLanguage: .britishEnglish, languageString: "British English")
                }
            }
        }
        .padding()
    }
}

struct MobileGameSettingsLanguagePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var selectedLanguage: SpeechLanguage
    
    let speechLanguage: SpeechLanguage
    let languageString: String
    let defaults = UserDefaults.standard
    
    var body: some View {
        Text("\(languageString)")
            .font(formatter.font(.regular, fontSize: .regular))
            .padding(7).padding(.horizontal, 3)
            .foregroundColor(formatter.color(selectedLanguage == speechLanguage ? .primaryFG : .highContrastWhite))
            .background(formatter.color(selectedLanguage == speechLanguage ? .highContrastWhite : .primaryFG))
            .clipShape(Capsule())
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


struct MobileGameSettingsVoiceSpeedView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var showingEditView = false
    @State var selectedSpeed: Float = UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5
    
    var emphasisColor: ColorType = .primaryFG
    var floatSpeedToString: [Float:String] {
        return [
            0.45 : "Slow",
            0.5 : "Medium",
            0.55 : "Fast",
        ]
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Reading Speed")
                Spacer()
                HStack (spacing: 5) {
                    Text(floatSpeedToString[selectedSpeed] ?? "Medium")
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: showingEditView ? 180 : 0))
                }
                .font(formatter.font(.regular))
                .foregroundColor(formatter.color(.lowContrastWhite))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingEditView.toggle()
            }
            if showingEditView {
                HStack (spacing: 7) {
                    Spacer()
                    MobileGameSettingsSpeedPickerView(selectedSpeed: $selectedSpeed, speechSpeed: .slow, speedString: "Slow")
                    MobileGameSettingsSpeedPickerView(selectedSpeed: $selectedSpeed, speechSpeed: .medium, speedString: "Medium")
                    MobileGameSettingsSpeedPickerView(selectedSpeed: $selectedSpeed, speechSpeed: .fast, speedString: "Fast")
                }
            }
        }
        .padding()
    }
}

struct MobileGameSettingsGenderView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @State var showingEditView = false
    @State var selectedGender: SpeechGender = SpeechGender(rawValue: UserDefaults.standard.string(forKey: "speechGender") ?? "male") ?? .male
    
    var body: some View {
        VStack {
            HStack {
                Text("Reading Voice")
                Spacer()
                HStack (spacing: 5) {
                    Text("\(selectedGender == .male ? "Male" : "Female")")
                    Image(systemName: "chevron.down")
                        .rotationEffect(Angle(degrees: showingEditView ? 180 : 0))
                }
                .font(formatter.font(.regular))
                .foregroundColor(formatter.color(.lowContrastWhite))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingEditView.toggle()
            }
            if showingEditView {
                HStack (spacing: 7) {
                    Spacer()
                    MobileGameSettingsGenderPickerView(selectedGender: $selectedGender, speechGender: .male, genderString: "Male")
                    MobileGameSettingsGenderPickerView(selectedGender: $selectedGender, speechGender: .female, genderString: "Female")
                }
            }
        }
        .padding()
    }
}

struct MobileGameSettingsGenderPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var selectedGender: SpeechGender
    
    let speechGender: SpeechGender
    let genderString: String
    let defaults = UserDefaults.standard
    
    var body: some View {
        Text("\(genderString)")
            .font(formatter.font(.regular, fontSize: .regular))
            .padding(7).padding(.horizontal, 3)
            .foregroundColor(formatter.color(selectedGender == speechGender ? .primaryFG : .highContrastWhite))
            .background(formatter.color(selectedGender == speechGender ? .highContrastWhite : .primaryFG))
            .clipShape(Capsule())
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

struct MobileGameSettingsSpeedPickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var selectedSpeed: Float
    
    let speechSpeed: SpeechSpeed
    let speedString: String
    let defaults = UserDefaults.standard
    
    var emphasisColor: ColorType = .primaryFG
    
    var body: some View {
        Text("\(speedString)")
            .font(formatter.font(.regular, fontSize: .regular))
            .padding(7).padding(.horizontal, 3)
            .foregroundColor(formatter.color(selectedSpeed == speechSpeed.rawValue ? .primaryFG : .highContrastWhite))
            .background(formatter.color(selectedSpeed == speechSpeed.rawValue ? .highContrastWhite : .primaryFG))
            .clipShape(Capsule())
            .onTapGesture {
                UserDefaults.standard.set(speechSpeed.rawValue, forKey: "speechSpeed")
                NotificationCenter.default.post(name: NSNotification.Name("SpeechSpeedChange"), object: nil)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("SpeechSpeedChange"), object: nil, queue: .main) { (_) in
                    let selectedSpeed = UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5
                    self.selectedSpeed = selectedSpeed
                }
            }
    }
}

struct MobileGameSettingsFooterView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var isPresentingGameView: Bool
    @Binding var isPresentingTrivioLiveView: Bool
    
    var gameIsPlayable: Bool {
        return participantsVM.teams.count > 0
    }
    
    var bgColor: Color {
        return formatter.color(.primaryBG)
    }
    
    var body: some View {
        HStack {
            Button(action: {
                if gameIsPlayable {
                    isPresentingGameView.toggle()
                    gamesVM.gameSetupMode = .play
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                }
            }, label: {
                Text("\(gamesVM.gameInProgress() ? "Resume Game" : "Play Game")")
                    .font(formatter.font(.boldItalic, fontSize: .regular))
                    .foregroundColor(formatter.color(.primaryFG))
                    .padding()
                    .background(formatter.color(.highContrastWhite))
                    .opacity(gameIsPlayable ? 1 : 0.5)
                    .clipShape(Capsule())
            })
            Button(action: {
                if gameIsPlayable {
                    isPresentingTrivioLiveView.toggle()
                    gamesVM.gameSetupMode = .play
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                }
            }, label: {
                Text("Host this game live!")
                    .font(formatter.font(.boldItalic, fontSize: .regular))
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .opacity(gameIsPlayable ? 1 : 0.5)
                    .clipShape(Capsule())
            })
        }
        .padding([.horizontal, .top])
        .background(formatter.color(.primaryBG).mask(LinearGradient(gradient: Gradient(colors: [bgColor, bgColor, bgColor, .clear]), startPoint: .bottom, endPoint: .top)))
    }
}

