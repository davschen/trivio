//
//  MobileSettingsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        VStack (spacing: -25) {
            HStack (spacing: 15) {
                Button(action: {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    profileVM.showingSettingsView.toggle()
                    profileVM.settingsMenuSelectedItem = "Game Settings"
                }, label: {
                    Image(systemName: "xmark")
                        .font(formatter.iconFont())
                })
                Text("Settings")
                    .font(formatter.font(fontSize: .extraLarge))
            }
            .padding()
            .padding(.top, 50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(.primaryFG))
            .edgesIgnoringSafeArea([.top, .horizontal])
            
            VStack {
                HStack {
                    menuItem(label: "Game Settings")
                    menuItem(label: "Account")
                }
                
                ZStack {
                    switch profileVM.settingsMenuSelectedItem {
                    case "Game Settings":
                        MobileSettingsGameSettingsView()
                    default:
                        MobileSettingsAccountSettingsView()
                    }
                }
                .background(formatter.color(.primaryFG))
                .cornerRadius(20)
            }
            .padding([.horizontal, .bottom])
        }
    }
    
    func menuItem(label: String) -> some View {
        Text(label)
            .font(formatter.font())
            .foregroundColor(formatter.color(profileVM.settingsMenuSelectedItem == label ? .highContrastWhite : .mediumContrastWhite))
            .padding()
            .frame(maxWidth: .infinity)
            .background(formatter.color(profileVM.settingsMenuSelectedItem == label ? .primaryAccent : .primaryBG))
            .cornerRadius(5)
            .onTapGesture {
                formatter.hapticFeedback(style: .soft, intensity: .strong)
                profileVM.settingsMenuSelectedItem = label
            }
    }
}

struct MobileSettingsGameSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (spacing: 20) {
                MobileGameSettingsVoiceTypeView(emphasisColor: .secondaryFG)
                MobileGameSettingsVoiceSpeedView(emphasisColor: .secondaryFG)
                MobileSettingsCustomizePlayerView()
                Spacer()
            }
            .padding()
        }
    }
}

struct MobileSettingsAccountSettingsView: View {
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
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            isEditingAccountSettings.toggle()
                        } label: {
                            Text("Cancel")
                                .font(formatter.font(fontSize: .small))
                        }
                    }
                    
                    Spacer()
                    Button {
                        if accountInformationError() { return }
                        if isEditingAccountSettings {
                            profileVM.checkUsernameValidWithHandler { (success) in
                                if success {
                                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                                    profileVM.editAccountInfo()
                                    isEditingAccountSettings.toggle()
                                    usernameTaken = false
                                } else {
                                    formatter.hapticFeedback(style: .rigid, intensity: .strong)
                                    usernameTaken = true
                                }
                            }
                        } else {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            isEditingAccountSettings.toggle()
                        }
                    } label: {
                        Text(isEditingAccountSettings ? "Save" : "Edit")
                            .font(formatter.font(fontSize: .small))
                            .foregroundColor(formatter.color(accountInformationError() ? .lowContrastWhite : .highContrastWhite))
                    }
                }
                Text("Account Settings")
                    .font(formatter.font())
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(formatter.color(.secondaryFG))
            
            if isEditingAccountSettings {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 20) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Username")
                                .font(formatter.font())
                            TextField("Edit Username", text: $profileVM.username)
                                .font(formatter.font(fontSize: .large))
                                .padding()
                                .background(formatter.color(.secondaryFG))
                                .accentColor(formatter.color(.secondaryAccent))
                                .cornerRadius(5)
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
                                .padding()
                                .background(formatter.color(.secondaryFG))
                                .accentColor(formatter.color(.secondaryAccent))
                                .cornerRadius(5)
                            if !nameError().isEmpty {
                                Text(nameError())
                                    .font(formatter.font(.boldItalic))
                                    .foregroundColor(formatter.color(.secondaryAccent))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            } else {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (alignment: .leading, spacing: 15) {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            
            if !isEditingAccountSettings {
                Button {
                    formatter.setAlertSettings(alertAction: {
                        profileVM.logOut()
                    }, alertTitle: "Log out?", alertSubtitle: "You're about to log out of your account.", hasCancel: true, actionLabel: "Confirm Log Out")
                } label: {
                    Text("Log Out")
                        .font(formatter.font(fontSize: .mediumLarge))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(formatter.color(.secondaryFG))
                        .cornerRadius(5)
                }
                .padding()
            }
        }
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

struct MobileSettingsCustomizePlayerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var textFieldFocused = false
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Customize Your Player")
                .font(formatter.font(fontSize: .mediumLarge))
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
            .font(formatter.font(fontSize: .semiLarge))
            .padding()
            .background(formatter.color(.secondaryFG))
            .accentColor(formatter.color(.secondaryAccent))
            .cornerRadius(5)
        }
    }
}

