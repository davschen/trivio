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
    @EnvironmentObject var appStoreManager: AppStoreManager
    
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var profileViewActive = false
    @State var allPublicSetsViewActive = false
    @State var allPrivateSetsViewActive = false
    @State var allRecentSetsViewActive = false
    @State var jeopardySeasonsViewActive = false
    
    var body: some View {
        NavigationView() {
            ZStack (alignment: .top) {
                // VStack for Trivio! Header
                VStack {
                    MobileHomepageHeaderView()
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack (alignment: .leading, spacing: 10) {
                            Spacer(minLength: 10)
                            // Was a Search bar that used :searchAndPull from exploreVM
                            MobileSetHorizontalScrollView(customSets: $gamesVM.customSets,
                                                          labelText: "My sets",
                                                          promptText: "View all") {
                                profileViewActive.toggle()
                            }
                            MobileExploreBuildPromptButtonView()
                            Spacer()
                                .frame(height: 5)
                            MobileSetHorizontalScrollView(customSets: $exploreVM.recentlyPlayedSets,
                                                          labelText: "Recently played",
                                                          promptText: "View all") {
                                allRecentSetsViewActive.toggle()
                            }
                            Spacer()
                                .frame(height: 5)
                            MobileSetHorizontalScrollView(customSets: $exploreVM.allPublicSets,
                                                          labelText: "Public sets",
                                                          promptText: "View all") {
                                allPublicSetsViewActive.toggle()
                            }
                            Spacer()
                                .frame(height: 5)
                            if profileVM.myUserRecords.isAdmin {
                                MobileSetHorizontalScrollView(customSets: $exploreVM.allPrivateSets,
                                                              labelText: "Private sets",
                                                              promptText: "View all") {
                                    allPrivateSetsViewActive.toggle()
                                }
                                Spacer()
                                    .frame(height: 5)
                            }
                            if profileVM.myUserRecords.isVIP {
                                MobileJeopardySetsView(jeopardySeasonsViewActive: $jeopardySeasonsViewActive)
                                Spacer()
                                    .frame(height: 5)
                            }
                        }
                        .padding(.bottom, 45)
                    }
                }
                if buildVM.dirtyBit > 0 && !buildVM.currCustomSet.title.isEmpty {
                    GeometryReader { reader in
                        formatter.color(.primaryFG)
                            .frame(height: reader.safeAreaInsets.top, alignment: .top)
                            .ignoresSafeArea()
                    }
                }
                NavigationLink(destination: MobileProfileView()
                    .navigationBarTitle("Profile", displayMode: .inline),
                               isActive: $profileViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
                NavigationLink(destination: MobileViewAllPublicSetsView()
                    .navigationBarTitle("All Public Sets", displayMode: .inline),
                               isActive: $allPublicSetsViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
                NavigationLink(destination: MobileViewAllPrivateSetsView(),
                               isActive: $allPrivateSetsViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
                NavigationLink(destination: MobileViewAllRecentSetsView()
                    .navigationBarTitle("All Played Sets", displayMode: .inline),
                               isActive: $allRecentSetsViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
                NavigationLink(destination: MobileJeopardySeasonsView()
                    .navigationBarTitle("All Seasons", displayMode: .inline),
                               isActive: $jeopardySeasonsViewActive,
                               label: { EmptyView() }).isDetailLink(false).hidden()
            }
            .navigationBarHidden(true)
            .withBackground()
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct MobileSetHorizontalScrollView: View {
    @EnvironmentObject var formatter: MasterHandler
    @Binding var customSets: [CustomSetCherry]
    
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
    @EnvironmentObject var buildVM : BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var buildViewActive = false
    @State var profileViewActive = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                if buildVM.dirtyBit > 0 && !buildVM.currCustomSet.title.isEmpty {
                    HStack (alignment: .center) {
                        VStack (alignment: .leading, spacing: 5) {
                            Text("Set in progress")
                                .font(formatter.font(fontSize: .small))
                            Text("Tap to continue editing “\(buildVM.currCustomSet.title)”")
                                .font(formatter.font(.regular, fontSize: .small))
                        }
                        Spacer()
                        Button {
                            buildVM.writeToFirestore()
                            // This is so sketchy and I should switch to either a completion handler or async await but I'm LAZY right now!
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                buildVM.clearAll()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .padding()
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 7)
                    .background(formatter.color(.primaryFG))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        buildViewActive.toggle()
                    }
                }
                HStack {
                    Text("Trivio!")
                        .font(formatter.font(fontSize: .large))
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
                                        .stroke(formatter.color(.highContrastWhite), lineWidth: 2)
                                )
                    }
                }
                .padding([.horizontal, .top], 15)
            }
            
            NavigationLink(destination: MobileProfileView()
                .navigationBarTitle("Profile", displayMode: .inline),
                           isActive: $profileViewActive,
                           label: { EmptyView() }).isDetailLink(false).hidden()
            NavigationLink (isActive: $buildViewActive) {
                MobileBuildView()
            } label: { EmptyView() }.hidden()
        }
    }
}

struct MobileExploreBuildPromptButtonView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    
    @State var isPresentingBuildView = false
    
    var body: some View {
        ZStack {
            VStack {
                Button {
                    isPresentingBuildView.toggle()
                    buildVM.start()
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
            }
            NavigationLink (isActive: $isPresentingBuildView) {
                MobileBuildView()
            } label: { EmptyView() }
                .hidden()
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
