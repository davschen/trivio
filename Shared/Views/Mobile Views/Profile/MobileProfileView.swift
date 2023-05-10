//
//  MobileProfileView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileProfileView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    
    @State var adminViewActive = false
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (alignment: .leading, spacing: 15) {
                MobileAccountInfoView()
                ZStack {
                    Button {
                        adminViewActive.toggle()
                    } label: {
                        HStack {
                            Text("Admin Dashboard")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                        }
                        .padding()
                        .background(formatter.color(.primaryFG))
                        .cornerRadius(10)
                        .padding(10)
                    }
                    NavigationLink (isActive: $adminViewActive) {
                        MobileAdminView()
                    } label: { EmptyView() }.hidden()
                }
                
                VStack (spacing: 40) {
                    if profileVM.myTriviaDeckClues.count > 0 {
                        MobileMyTriviaDecksPreviewView()
                    }
                    VStack (alignment: .leading, spacing: 10) {
                        Text("My Jeopardy-style Sets")
                            .font(formatter.font(.semiBold, fontSize: .mediumLarge))
                            .kerning(-1.5)
                            .padding(.horizontal, 10)
                        MobileMyCustomSetsView(customSets: $gamesVM.customSets)
                    }
                    if profileVM.drafts.count > 0 {
                        VStack (alignment: .leading, spacing: 10) {
                            Text("My Drafts")
                                .font(formatter.font(.semiBold, fontSize: .mediumLarge))
                                .kerning(-1.5)
                                .padding(.horizontal, 10)
                            MobileMyDraftsView()
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.bottom, 25)
        }
        .withBackground()
        .withBackButton()
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MobileMyTriviaDecksPreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var myTriviaDecksViewActive = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                Text("My Trivia Deck Clues")
                    .font(formatter.font(.semiBold, fontSize: .mediumLarge))
                    .kerning(-1.5)
                Spacer()
                Button {
                    formatter.hapticFeedback(style: .medium)
                    myTriviaDecksViewActive.toggle()
                } label: {
                    Text("More")
                        .foregroundColor(formatter.color(.secondaryAccent))
                }
            }
            .padding(.horizontal, 10)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 10) {
                    ForEach(profileVM.myTriviaDeckClues.prefix(5), id: \.self) { triviaDeckClue in
                        ZStack {
                            MobileMyTriviaDecksCellView(triviaDeckClue: triviaDeckClue)
                                .onTapGesture {
                                    formatter.hapticFeedback(style: .medium)
                                    myTriviaDecksViewActive.toggle()
                                }
                            NavigationLink (isActive: $myTriviaDecksViewActive) {
                                MobileMyTriviaDecksView()
                            } label: { EmptyView() }.hidden()
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }
}

struct MobileAccountInfoView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        Button {
            formatter.hapticFeedback(style: .heavy, intensity: .weak)
            profileVM.showingSettingsView.toggle()
            profileVM.settingsMenuSelectedItem = "Account"
        } label: {
            ZStack {
                HStack (spacing: 5) {
                    Text("\(exploreVM.getInitialsFromUserID(userID: profileVM.myUID ?? ""))")
                        .font(formatter.font(.boldItalic, fontSize: .regular))
                        .frame(width: 50, height: 50)
                        .background(formatter.color(.primaryAccent))
                        .clipShape(Circle())
                        .overlay(
                                Circle()
                                    .stroke(formatter.color(.highContrastWhite), lineWidth: 1.5)
                            )
                    VStack (alignment: .leading, spacing: 3) {
                        Text("\(profileVM.myTrivioUser.name)")
                            .font(formatter.font(.bold, fontSize: .mediumLarge))
                        Text("@\(profileVM.myTrivioUser.username)")
                            .font(formatter.font(.regular, fontSize: .regular))
                        Text("Subscribed to Trivio! Pro")
                            .font(formatter.font(.regular, fontSize: .regular))
                            .foregroundColor(formatter.color(.mediumContrastWhite))
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                }
                .padding(.horizontal)
                
                NavigationLink(destination: MobileAccountSettingsView(),
                               isActive: $profileVM.showingSettingsView,
                               label: { EmptyView() }).hidden()
            }
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
                .font(formatter.font(.boldItalic))
                .foregroundColor(formatter.color(.lowContrastWhite))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 145)
        .padding()
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
}

