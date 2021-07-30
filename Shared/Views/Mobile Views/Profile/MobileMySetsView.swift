//
//  MobileMySetsView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileMySetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if gamesVM.customSets.count > 0 {
                MobileCustomSetView(searchItem: $profileVM.searchItem, isMine: true, customSets: gamesVM.customSets)
            } else {
                MobileEmptyListView(label: "Nothing yet! When you make a set, it’ll show up here.")
                    .padding()
            }
        }
        .keyboardAware()
        .withBackButton()
    }
}

struct MobileCustomSetView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var searchItem: String
    
    @State var previewViewActive = false
    
    var isInUserView = false
    var isMine: Bool
    var customSets: [CustomSet]
    
    var body: some View {
        VStack {
            if isMine {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .bold))
                    TextField("Search your sets", text: $searchItem)
                        .font(formatter.font())
                        .accentColor(formatter.color(.secondaryAccent))
                        .foregroundColor(formatter.color(.highContrastWhite))
                    if searchItem.isEmpty {
                        Button {
                            searchItem.removeAll()
                            formatter.resignKeyboard()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .foregroundColor(formatter.color(.lowContrastWhite))
                .padding()
                .background(formatter.color(.secondaryFG))
                .cornerRadius(5)
                .padding(.top)
            }
            
            ScrollView (.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: 10)
                VStack {
                    ForEach(customSets, id: \.self) { set in
                        if searchItem.isEmpty || set.title.contains(searchItem) {
                            MobileCustomSetCellView(isInUserView: isInUserView, set: set, isMine: isMine)
                                .onTapGesture {
                                    if gamesVM.gameInProgress() {
                                        formatter.setAlertSettings(alertAction: {
                                            selectSet(set: set)
                                        }, alertTitle: "Cancel current game?", alertSubtitle: "It looks like you have a game in progress. Choosing this one would erase all of your progress.", hasCancel: true, actionLabel: "Yes, choose this game")
                                    } else {
                                        selectSet(set: set)
                                    }
                                }
                        }
                    }
                    NavigationLink(destination: MobileSetPreviewView()
                                    .navigationBarTitle("Preview", displayMode: .inline),
                                   isActive: $previewViewActive,
                                   label: {}).hidden()
                    NavigationLink(destination: EmptyView()) {
                        EmptyView()
                    }.hidden()
                }
                Spacer()
                    .frame(height: 10)
            }
        }
        .padding(.horizontal)
    }
    
    func selectSet(set: CustomSet) {
        formatter.hapticFeedback(style: .light)
        guard let setID = set.id else { return }
        gamesVM.getCustomData(setID: setID)
        gamesVM.setEpisode(ep: setID)
        gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
        participantsVM.resetScores()
        previewViewActive = true
    }
}

struct MobileCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var userViewActive = false
    
    var isInUserView = false
    var set: CustomSet
    var isMine: Bool
    var setID: String {
        return set.id ?? "NID"
    }
    var played: Bool {
        return profileVM.beenPlayed(gameID: setID)
    }
    var selected: Bool {
        return gamesVM.selectedEpisode == setID
    }
    var rating: String {
        if set.rating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.01f", round(set.rating * 10) / 10.0))/5"
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                if !set.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                Text("\(set.title)")
                    .font(formatter.font(fontSize: .semiLarge))
                Spacer()
            }
            HStack {
                Text("\(set.numclues) clues")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                HStack (spacing: 3) {
                    Text("\(rating)")
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(set.plays) plays")
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 10)
                Text("\(gamesVM.dateFormatter.string(from: set.dateCreated))")
            }
            .font(formatter.font(.regular, fontSize: .small))
            .foregroundColor(formatter.color(.highContrastWhite))
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                    ForEach(set.tags, id: \.self) { tag in
                        Text("#" + tag.uppercased())
                            .font(formatter.font(.boldItalic, fontSize: .small))
                            .foregroundColor(formatter.color(.primaryFG))
                            .padding(7)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                }
            }
            if isMine {
                HStack {
                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        buildVM.edit(gameID: setID)
                        buildVM.isEditingDraft = false
                    }, label: {
                        Text("Edit")
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .font(formatter.font(fontSize: .medium))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(formatter.color(.primaryAccent))
                            .cornerRadius(5)
                    })
                    Button(action: {
                        formatter.setAlertSettings(alertAction: {
                            buildVM.deleteSet(setID: setID)
                            gamesVM.deleteSet(setID: setID)
                            gamesVM.setEpisode(ep: "")
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                        }, alertTitle: "Are You Sure?", alertSubtitle: "Deleting your set is irreversible. Your set \"\(set.title)\" has been played \(set.plays) times with a rating of \(String(format: "%.01f", round(set.rating * 10) / 10.0)) out of 5.", hasCancel: true, actionLabel: "Delete")
                    }, label: {
                        Text("Delete")
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .font(formatter.font(fontSize: .medium))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(formatter.color(.lowContrastWhite).opacity(0.5))
                            .cornerRadius(5)
                    })
                }
            } else if !isInUserView {
                MobileUserProfileButtonView(userViewActive: $userViewActive, set: set)
            }
        }
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
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

