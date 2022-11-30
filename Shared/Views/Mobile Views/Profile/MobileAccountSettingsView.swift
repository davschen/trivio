//
//  MobileAccountSettingsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileAccountSettingsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var isEditingAccountSettings = false
    @State var usernameTaken = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            if isEditingAccountSettings {
                MobileAccountSettingsEditView(usernameTaken: $usernameTaken)
            } else {
                MobileAccountSettingsDisplayView()
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
                        .cornerRadius(10)
                        .padding(.bottom, 15)
                }
                .padding()
            }
        }
        .withBackground()
        .edgesIgnoringSafeArea(.bottom)
        .withBackButton()
        .navigationTitle("Account Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    if profileVM.accountInformationError(usernameTaken: usernameTaken) { return }
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
                }) {
                    Text(isEditingAccountSettings ? "Save" : "Edit")
                        .font(formatter.font(fontSize: .regular))
                        .foregroundColor(formatter.color(profileVM.accountInformationError(usernameTaken: usernameTaken) ? .lowContrastWhite : .highContrastWhite))
                }
            }
        }
    }
}

struct MobileAccountSettingsEditView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var usernameTaken: Bool
    
    var body: some View {
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
                    if !profileVM.usernameError(usernameTaken: usernameTaken).isEmpty {
                        Text(profileVM.usernameError(usernameTaken: usernameTaken))
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
                    if !profileVM.nameError().isEmpty {
                        Text(profileVM.nameError())
                            .font(formatter.font(.boldItalic))
                            .foregroundColor(formatter.color(.secondaryAccent))
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MobileAccountSettingsDisplayView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .leading, spacing: 25) {
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
                        .font(formatter.font(.regular, fontSize: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if profileVM.myUserRecords.isAdmin {
                    VStack (alignment: .leading, spacing: 5) {
                        Text("Showing admin UI features")
                            .font(formatter.font())
                        HStack {
                            Text("Yes")
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(formatter.color(profileVM.myUserRecords.isAdmin ? .secondaryFG : .primaryFG))
                                .cornerRadius(5)
                                .onTapGesture {
                                    profileVM.myUserRecords.isAdmin = true
                                }
                            Text("No")
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(formatter.color(profileVM.myUserRecords.isAdmin ? .primaryFG : .secondaryFG))
                                .cornerRadius(5)
                                .onTapGesture {
                                    profileVM.myUserRecords.isAdmin = false
                                }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
