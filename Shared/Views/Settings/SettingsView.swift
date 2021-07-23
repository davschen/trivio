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
            HStack (spacing: 15) {
                Button(action: {
                    profileVM.showingSettingsView.toggle()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30, weight: .bold))
                })
                Text("Settings")
                    .font(formatter.font(fontSize: .extraLarge))
            }
            .padding(30)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(.primaryFG))
            .edgesIgnoringSafeArea([.top, .horizontal])
            
            HStack {
                ScrollView (.vertical) {
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
                        ScrollView (.vertical) {
                            VStack (spacing: 20) {
                                GameSettingsVoiceTypeView(emphasisColor: .secondaryFG)
                                GameSettingsVoiceSpeedView(emphasisColor: .secondaryFG)
                                SettingsCustomizePlayerView()
                                Spacer()
                            }
                            .padding(30)
                        }
                    default:
                        VStack {
                            
                        }
                        .padding(30)
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

struct SettingsCustomizePlayerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            Text("Customize Your Player")
                .font(formatter.font(fontSize: .large))
//            TextField("Add Name", text: $team.name)
//                .font(formatter.font(fontSize: .large))
//                .padding()
//                .background(formatter.color(.secondaryFG))
//                .accentColor(formatter.color(.secondaryAccent))
//                .cornerRadius(10)
        }
    }
}
