//
//  MySetsView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/15/21.
//

import Foundation
import SwiftUI

struct MySetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            Text("My Sets")
                .font(formatter.font(fontSize: .extraLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
            if gamesVM.previewViewShowing {
                GamePreviewView()
                    .padding(5)
            }
            if gamesVM.customSets.count > 0 {
                CustomSetView(searchItem: $profileVM.searchItem, isMine: true, customSets: gamesVM.customSets)
                    .padding(5)
                Spacer()
            } else {
                EmptyListView(label: "Nothing yet! When you make a set, it’ll show up here.")
                    .padding(.vertical, 30)
            }
        }
        .keyboardAware()
    }
}

struct CustomSetView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var searchItem: String
    
    var isMine: Bool
    var customSets: [CustomSet]
    var columns: [GridItem] = [GridItem](repeating: GridItem(spacing: 15), count: 2)
    
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
                .padding(.horizontal, 2)
            }
            
            ScrollView (.vertical, showsIndicators: false) {
                Spacer()
                    .frame(height: 10)
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(customSets, id: \.self) { set in
                        if searchItem.isEmpty || set.title.contains(searchItem) {
                            CustomSetCellView(set: set, isMine: isMine)
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
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    func selectSet(set: CustomSet) {
        guard let setID = set.id else { return }
        gamesVM.getCustomData(setID: setID)
        gamesVM.previewViewShowing = true
        gamesVM.setCustomSetID(ep: setID)
        gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
        participantsVM.resetScores()
    }
}

struct CustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var set: CustomSet
    var isMine: Bool
    var setID: String {
        return set.id ?? "NID"
    }
    var played: Bool {
        return profileVM.beenPlayed(gameID: setID)
    }
    var selected: Bool {
        return gamesVM.customSet.id == setID
    }
    var rating: String {
        if set.rating == 0 {
            return "N/A"
        } else {
            return "\(String(format: "%.01f", round(set.rating * 10) / 10.0))/5"
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack {
                if !set.isPublic {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                }
                Text("\(set.title)")
                    .font(formatter.font(fontSize: .mediumLarge))
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
                            gamesVM.setCustomSetID(ep: "")
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
            } else if !exploreVM.isShowingUserView {
                Button(action: {
                    exploreVM.isShowingUserView.toggle()
                    exploreVM.pullAllFromUser(withID: set.userID)
                    gamesVM.previewViewShowing = false
                }, label: {
                    HStack {
                        Image(systemName: "person.circle")
                            .font(.system(size: 15, weight: .bold))
                        Text("\(exploreVM.getUsernameFromUserID(userID: set.userID))'s Profile")
                            .font(formatter.font(fontSize: .medium))
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(formatter.color(.primaryAccent))
                    .cornerRadius(5)
                })
            }
        }
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
        .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(formatter.color(.highContrastWhite),
                                lineWidth: gamesVM.customSet.id == setID ? 5 : 0))
    }
}
