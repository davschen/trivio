//
//  MobileMySetsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileCustomSetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    @Binding var customSets: [CustomSet]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if customSets.count > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer(minLength: 15)
                        ForEach(customSets, id: \.self) { customSet in
                            MobileCustomSetCellView(customSet: customSet)
                        }
                        Spacer(minLength: 15)
                    }
                }
            } else {
                MobileEmptyListView(label: "Nothing yet! When you make a set, it’ll show up here.")
                    .padding()
            }
        }
        .keyboardAware()
    }
}

struct MobileCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var setPreviewActive = false
    
    var isInUserView = false
    var customSet: CustomSet
    var setID: String {
        return customSet.id ?? "NID"
    }
    var played: Bool {
        return profileVM.beenPlayed(gameID: setID)
    }
    var selected: Bool {
        return gamesVM.customSet.id == setID
    }
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 7) {
                Text(customSet.title)
                    .font(formatter.font(fontSize: .mediumLarge))
                Text("2 rounds, \(customSet.numclues) clues")
                    .font(formatter.font(.regular))
                Text("Tags: \(customSet.tags.map{String($0).lowercased()}.joined(separator: ", "))")
                    .font(formatter.font(.regular))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                    .padding(.bottom, 5)
                HStack {
                    Text("\(exploreVM.getInitialsFromUserID(userID: customSet.userID))")
                        .font(formatter.font(.boldItalic, fontSize: .small))
                        .frame(width: 35, height: 35)
                        .background(formatter.color(.primaryAccent))
                        .clipShape(Circle())
                    VStack (alignment: .leading, spacing: 2) {
                        Text("\(exploreVM.getUsernameFromUserID(userID: customSet.userID))")
                            .font(formatter.font(.regular))
                        HStack {
                            Text("\(customSet.plays) plays")
                            Circle()
                                .frame(width: 5, height: 5)
                            Text("\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
                        }
                        .font(formatter.font(.regular))
                        .foregroundColor(formatter.color(.lowContrastWhite))
                    }
                }
            }
            
            NavigationLink(destination: MobileGameSettingsView()
                .navigationBarTitle("Set Preview", displayMode: .inline),
                           isActive: $setPreviewActive,
                           label: { EmptyView() }).hidden()
        }
        .padding(.horizontal, 15).padding(.vertical, 20)
        .frame(width: 250, height: 145, alignment: .leading)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            selectSet(customSet: customSet)
            setPreviewActive.toggle()
        }
    }
    
    func selectSet(customSet: CustomSet) {
        formatter.hapticFeedback(style: .light)
        guard let setID = customSet.id else { return }
        gamesVM.reset()
        gamesVM.getCustomData(setID: setID)
        gamesVM.setCustomSetID(ep: setID)
        gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
        participantsVM.resetScores()
    }
}

struct MobileUserProfileButtonView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    
    @Binding var userViewActive: Bool
    
    var set: CustomSet
    
    var body: some View {
        ZStack {
            NavigationLink(destination: MobileUserView()
                            .navigationBarTitle("Profile", displayMode: .inline),
                           isActive: $userViewActive,
                           label: {}).hidden()
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }.hidden()
            Button(action: {
                formatter.hapticFeedback(style: .light)
                exploreVM.pullAllFromUser(withID: set.userID)
                userViewActive.toggle()
            }, label: {
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 15, weight: .bold))
                    Text("\(exploreVM.getUsernameFromUserID(userID: set.userID))'s Profile")
                        .font(formatter.font(fontSize: .medium))
                }
                .foregroundColor(formatter.color(.highContrastWhite))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(5)
            })
        }
    }
}


