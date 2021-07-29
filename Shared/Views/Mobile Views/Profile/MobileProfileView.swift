//
//  MobileProfileView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileProfileView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        ZStack {
            if buildVM.showingBuildView {
                MobileBuildView()
                    .transition(.move(edge: .bottom))
                    .withBackground()
            } else if profileVM.showingSettingsView {
                MobileSettingsView()
                    .transition(.move(edge: .bottom))
                    .withBackground()
            } else {
                NavigationView() {
                    MobileProfileMainView()
                        .withHeader("Profile")
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

struct MobileProfileMainView: View {

    var body: some View {
        VStack {
            MobileAccountInfoView()
            ScrollView (.vertical, showsIndicators: false) {
                MobileProfileMenuSelectionView()
            }
            MobileProfileBottomButtonsView()
        }
        .padding([.horizontal, .bottom])
    }
}

struct MobileAccountInfoView: View {
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
                formatter.hapticFeedback(style: .light)
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

struct MobileProfileMenuSelectionView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (spacing: 30) {
            MobileMenuSelectionView(label: "Summary", transitionToView: AnyView(MobileSummaryView().withBackButton()))
            MobileMenuSelectionView(label: "My Sets", transitionToView: AnyView(MobileMySetsView().withBackButton()))
            MobileMenuSelectionView(label: "My Drafts", transitionToView: AnyView(MobileDraftsView().withBackButton()))
            MobileMenuSelectionView(label: "Past Games", transitionToView: AnyView(MobileReportsView().withBackButton()))
        }
        .padding()
    }
}

struct MobileMenuSelectionView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var selectionViewActive = false
    
    let label: String
    let transitionToView: AnyView
    
    var body: some View {
        ZStack {
            Button {
                formatter.hapticFeedback(style: .light)
                selectionViewActive.toggle()
            } label: {
                HStack {
                    Text(label)
                        .font(formatter.font(fontSize: .mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(formatter.iconFont())
                }
            }
            NavigationLink(destination: transitionToView
                            .navigationBarTitle(label, displayMode: .inline),
                           isActive: $selectionViewActive,
                           label: { EmptyView() }).hidden()
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }.hidden()
        }
    }
}

struct MobileProfileBottomButtonsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        VStack (spacing: 10) {
            Button(action: {
                formatter.hapticFeedback(style: .light)
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
                formatter.hapticFeedback(style: .light)
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

struct MobileEmptyListView: View {
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

