//
//  ProfileView.swift
//  Trivio
//
//  Created by David Chen on 3/22/21.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    @State var isShowingMenu = true
    @State var menuOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if buildVM.showingBuildView {
                BuildView()
                    .transition(.move(edge: .bottom))
            } else if profileVM.showingSettingsView {
                SettingsView()
                    .transition(.move(edge: .bottom))
            } else {
                ProfileMainView()
            }
        }
    }
}

struct ProfileMainView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        HStack (spacing: 30) {
            // Menu
            VStack {
                AccountInfoView()
                ProfileMenuSelectionView()
                Spacer()
                ProfileBottomButtonsView()
            }
            .frame(width: UIScreen.main.bounds.width * 0.25)
            .padding([.leading, .vertical], 30)
            ZStack {
                switch profileVM.menuSelectedItem {
                case "Summary":
                    SummaryView()
                case "My Drafts":
                    DraftsView()
                case "Past Games":
                    ReportsView()
                default:
                    MySetsView()
                }
            }
            .padding([.trailing, .top], 30)
        }
    }
}

struct AccountInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                Text("\(profileVM.name)")
                    .font(formatter.font(.bold, fontSize: .large))
                    .foregroundColor(formatter.color(.highContrastWhite))
                Text("@\(profileVM.username)")
                    .font(formatter.font(.regular, fontSize: .medium))
                    .foregroundColor(formatter.color(.highContrastWhite))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            
            Button(action: {
                profileVM.showingSettingsView.toggle()
                profileVM.settingsMenuSelectedItem = "Account"
            }, label: {
                Text("Edit Info")
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .font(formatter.font(.bold, fontSize: .medium))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
            })
        }
        .padding()
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuSelectionView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack {
                Spacer()
                    .frame(height: 15)
                menuSelectionView(label: "Summary")
                menuSelectionView(label: "My Sets")
                menuSelectionView(label: "My Drafts")
                menuSelectionView(label: "Past Games")
            }
        }
    }
    
    func menuSelectionView(label: String) -> some View {
        Text(label)
            .font(formatter.font())
            .foregroundColor(formatter.color(profileVM.menuSelectedItem == label ? .highContrastWhite : .mediumContrastWhite))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(formatter.color(profileVM.menuSelectedItem == label ? .primaryAccent : .primaryBG))
            .cornerRadius(5)
            .animation(nil)
            .onTapGesture {
                profileVM.menuSelectedItem = label
            }
    }
}

struct ProfileBottomButtonsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Button(action: {
                buildVM.start()
            }, label: {
                HStack {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 15, weight: .bold))
                    Text("Build a Set")
                        .font(formatter.font())
                }
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.secondaryAccent))
                .cornerRadius(5)
            })
            
            Button(action: {
                profileVM.showingSettingsView.toggle()
            }, label: {
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 15, weight: .bold))
                    Text("Settings")
                        .font(formatter.font())
                }
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
            })
        }
    }
}

struct EmptyListView: View {
    @EnvironmentObject var formatter: MasterHandler
    var label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(formatter.font(.regularItalic))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
}
