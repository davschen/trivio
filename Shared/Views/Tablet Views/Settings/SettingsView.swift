//
//  SettingsView.swift
//  Trivio!
//
//  Created by David Chen on 7/22/21.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        VStack (spacing: 15) {
            HStack (spacing: 10) {
                Button(action: {
                    profileVM.showingSettingsView.toggle()
                    profileVM.settingsMenuSelectedItem = "Game Settings"
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30, weight: .bold))
                })
                Text("Settings")
                    .font(formatter.font(fontSize: .extraLarge))
            }
            .padding(30)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(.primaryFG))
            .edgesIgnoringSafeArea([.top, .horizontal])
            
            HStack {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack {
                        menuItem(label: "Game Settings")
                        menuItem(label: "Account")
                    }
                    .frame(width: 300)
                    .padding([.leading, .top], 30)
                }
                
                ZStack {
                    switch profileVM.settingsMenuSelectedItem {
                    case "Game Settings":
                        SettingsGameSettingsView()
                    default:
                        SettingsAccountSettingsView()
                    }
                }
                .background(formatter.color(.primaryFG))
                .cornerRadius(30)
                .padding([.horizontal, .bottom], 30)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func menuItem(label: String) -> some View {
        Text(label)
            .font(formatter.font())
            .foregroundColor(formatter.color(profileVM.settingsMenuSelectedItem == label ? .highContrastWhite : .mediumContrastWhite))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(profileVM.settingsMenuSelectedItem == label ? .primaryAccent : .primaryBG))
            .cornerRadius(5)
            .animation(nil)
            .onTapGesture {
                profileVM.settingsMenuSelectedItem = label
            }
    }
}

struct SettingsGameSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (spacing: 20) {
                GameSettingsVoiceTypeView(emphasisColor: .secondaryFG)
                GameSettingsVoiceSpeedView(emphasisColor: .secondaryFG)
                SettingsCustomizePlayerView()
                Spacer()
            }
            .padding(30)
            .keyboardAware()
        }
    }
}

struct SettingsAccountSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var isEditingAccountSettings = false
    @State var usernameTaken = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            ZStack {
                HStack {
                    if isEditingAccountSettings {
                        Button {
                            isEditingAccountSettings.toggle()
                        } label: {
                            Text("Cancel")
                                .font(formatter.font())
                        }
                    }
                    
                    Spacer()
                    Button {
                        if accountInformationError() { return }
                        if isEditingAccountSettings {
                            profileVM.checkUsernameValidWithHandler { (success) in
                                if success {
                                    profileVM.editAccountInfo()
                                    isEditingAccountSettings.toggle()
                                    usernameTaken = false
                                } else {
                                    usernameTaken = true
                                }
                            }
                        } else {
                            isEditingAccountSettings.toggle()
                        }
                    } label: {
                        Text(isEditingAccountSettings ? "Save" : "Edit")
                            .font(formatter.font())
                            .foregroundColor(formatter.color(accountInformationError() ? .lowContrastWhite : .highContrastWhite))
                    }
                }
                Text("Account Settings")
                    .font(formatter.font(fontSize: .mediumLarge))
            }
            .frame(maxWidth: .infinity)
            .padding(30)
            .background(formatter.color(.secondaryFG))
            
            if isEditingAccountSettings {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 20) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Username")
                                .font(formatter.font())
                            TextField("Edit Username", text: $profileVM.username)
                                .font(formatter.font(fontSize: .large))
                                .padding(20)
                                .background(formatter.color(.secondaryFG))
                                .accentColor(formatter.color(.secondaryAccent))
                                .cornerRadius(10)
                                .onChange(of: profileVM.username) { change in
                                    profileVM.checkUsernameExists { (success) in
                                        if success {
                                            self.usernameTaken = false
                                        } else {
                                            self.usernameTaken = true
                                        }
                                    }
                                }
                            if !usernameError().isEmpty {
                                Text(usernameError())
                                    .font(formatter.font(.boldItalic))
                                    .foregroundColor(formatter.color(.secondaryAccent))
                            }
                        }
                        
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Name")
                                .font(formatter.font())
                            TextField("Edit Name", text: $profileVM.name)
                                .font(formatter.font(fontSize: .large))
                                .padding(20)
                                .background(formatter.color(.secondaryFG))
                                .accentColor(formatter.color(.secondaryAccent))
                                .cornerRadius(10)
                            if !nameError().isEmpty {
                                Text(nameError())
                                    .font(formatter.font(.boldItalic))
                                    .foregroundColor(formatter.color(.secondaryAccent))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(30)
            } else {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 20) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Username")
                                .font(formatter.font())
                            Text(profileVM.username)
                                .font(formatter.font(fontSize: .semiLarge))
                        }
                        
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Name")
                                .font(formatter.font())
                            Text(profileVM.name)
                                .font(formatter.font(fontSize: .semiLarge))
                        }
                        
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Phone number")
                                .font(formatter.font())
                            Text(profileVM.getPhoneNumber())
                                .font(formatter.font(fontSize: .semiLarge))
                            Text("We want to remind you that Trivio! never looks at, sells, or distributes your personal data in any way. It is simply used for user verification.")
                                .font(formatter.font(.regular, fontSize: .small))
                                .frame(width: 300, alignment: .leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(30)
            }
            
            if !isEditingAccountSettings {
                Button {
                    formatter.setAlertSettings(alertAction: {
                        profileVM.logOut()
                    }, alertTitle: "Log out?", alertSubtitle: "You're about to log out of your account.", hasCancel: true, actionLabel: "Confirm Log Out")
                } label: {
                    Text("Log Out")
                        .font(formatter.font(fontSize: .mediumLarge))
                        .frame(width: 300)
                        .padding(.vertical)
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(5)
                }
                .padding(30)
            }
        }
        .keyboardAware()
    }
    
    func accountInformationError() -> Bool {
        return !nameError().isEmpty || !usernameError().isEmpty
    }
    
    func usernameError() -> String {
        if usernameTaken {
            return "That username is already taken"
        } else if profileVM.username.isEmpty {
            return "Your username cannot be empty"
        } else if !profileVM.checkForbiddenChars().isEmpty {
            return "Your username cannot contain a " + profileVM.checkForbiddenChars()
        } else {
            return ""
        }
    }
    
    func nameError() -> String {
        if profileVM.name.isEmpty {
            return "Your name cannot be empty"
        } else {
            return ""
        }
    }
}

struct SettingsCustomizePlayerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var textFieldFocused = false
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Customize Your Player")
                .font(formatter.font(fontSize: .large))
            HStack (spacing: 15) {
                if textFieldFocused {
                    Button {
                        participantsVM.editTeamInDB(team: participantsVM.myTeam)
                        if participantsVM.teams.contains(participantsVM.myTeam) {
                            participantsVM.teams[participantsVM.myTeam.index].editName(name: participantsVM.myTeam.name)
                        }
                        formatter.resignKeyboard()
                        textFieldFocused.toggle()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 25, weight: .bold))
                    }
                }
                TextField("Add Name", text: $participantsVM.myTeam.name, onEditingChanged: { focused in
                    if focused {
                        textFieldFocused = true
                    }
                })
            }
            .font(formatter.font(fontSize: .large))
            .padding(20)
            .background(formatter.color(.secondaryFG))
            .accentColor(formatter.color(.secondaryAccent))
            .cornerRadius(10)
            
            HStack {
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.blue), colorString: "blue", isSettingsPicker: true)
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.purple), colorString: "purple", isSettingsPicker: true)
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.green), colorString: "green", isSettingsPicker: true)
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.yellow), colorString: "yellow", isSettingsPicker: true)
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.orange), colorString: "orange", isSettingsPicker: true)
                ColorPickerView(team: $participantsVM.myTeam, color: formatter.color(.red), colorString: "red", isSettingsPicker: true)
            }
        }
    }
}
