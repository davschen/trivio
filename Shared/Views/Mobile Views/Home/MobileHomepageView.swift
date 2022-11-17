//
//  MobileExploreView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileHomepageView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        NavigationView() {
            // ZStack is for background color purposes only
            ZStack {
                formatter.color(.primaryBG)
                    .edgesIgnoringSafeArea(.all)
                // VStack for Trivio! Header
                VStack {
                    MobileHomepageHeaderView()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack (alignment: .leading, spacing: 10) {
                            Spacer(minLength: 10)
                            // Was a Search bar that used :searchAndPull from exploreVM
                            MobileSetHorizontalScrollView(customSets: $gamesVM.customSets,
                                                          labelText: "My sets",
                                                          promptText: "More") {
                                print("More my sets")
                            }
                            MobileExploreBuildPromptButtonView()
                            Spacer()
                                .frame(height: 5)
                            MobileSetHorizontalScrollView(customSets: $exploreVM.recentlyPlayedSets,
                                                          labelText: "Recently played",
                                                          promptText: "View all") {
                                print("See all recents")
                            }
                            Spacer()
                                .frame(height: 5)
                            MobileSetHorizontalScrollView(customSets: $exploreVM.allPublicSets,
                                                          labelText: "Public sets",
                                                          promptText: "View all") {
                                print("See all publics")
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MobileSetHorizontalScrollView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var customSets: [CustomSet]
    
    let labelText: String
    let promptText: String
    let buttonAction: () -> ()
    
    var body: some View {
        HStack {
            Text("\(labelText)")
            Spacer()
            Button {
                buttonAction()
            } label: {
                Text("\(promptText)")
                    .foregroundColor(formatter.color(.secondaryAccent))
            }
        }
        .padding(.horizontal, 15)
        MobileCustomSetsView(customSets: $customSets)
    }
}

struct MobileHomepageHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var profileViewActive = false
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "magnifyingglass")
                Spacer()
                Text("Trivio!")
                    .font(formatter.font(fontSize: .mediumLarge))
                Spacer()
                Button {
                    profileViewActive.toggle()
                } label: {
                    Text("\(exploreVM.getInitialsFromUserID(userID: profileVM.myUID ?? ""))")
                        .font(formatter.font(.boldItalic, fontSize: .micro))
                        .frame(width: 30, height: 30)
                        .background(formatter.color(.primaryAccent))
                        .clipShape(Circle())
                        .overlay(
                                Circle()
                                    .stroke(formatter.color(.highContrastWhite), lineWidth: 3)
                            )
                }
            }
            
            NavigationLink(destination: MobileProfileView()
                .navigationBarTitle("Profile", displayMode: .inline),
                           isActive: $profileViewActive,
                           label: { EmptyView() }).isDetailLink(false).hidden()
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }.hidden()
        }
        .padding([.horizontal, .top], 15)
    }
}

struct MobileExploreBuildPromptButtonView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    var body: some View {
        ZStack {
            Button {
                buildVM.showingBuildView.toggle()
            } label: {
                HStack {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Build a Set!")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(10)
                .padding(.horizontal, 15)
            }
            NavigationLink (isActive: $buildVM.showingBuildView) {
                MobileBuildView()
            } label: { EmptyView() }
                .isDetailLink(false)
                .hidden()
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }
        }
    }
}

struct MobileExploreSectionHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    let labelText: String
    let promptText: String
    var buttonAction: () -> ()
    
    var body: some View {
        HStack {
            Text("\(labelText)")
            Spacer()
            Button {
                buttonAction()
            } label: {
                Text("\(promptText)")
                    .foregroundColor(formatter.color(.secondaryAccent))
            }
        }
        .padding(.horizontal, 15)
    }
}
