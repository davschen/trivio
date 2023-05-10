//
//  MobileMyCustomSetsView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/18/22.
//

import Foundation
import SwiftUI

struct MobileMyCustomSetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State var idSelected = ""
    
    @Binding var customSets: [CustomSetDurian]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            if customSets.count > 0 {
                VStack (alignment: .leading, spacing: 40) {
                    ForEach(customSets, id: \.self) { customSet in
                        MobileMyCustomSetCellView(customSet: customSet)
                            .animation(.easeInOut(duration: 0.2))
                    }
                }
            } else {
                MobileEmptyListView(label: "You haven’t made any sets yet. Once you do, they’ll show up here.")
                    .padding(.horizontal)
            }
        }
    }
}

struct MobileMyCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var currentCategoryIndex: Int = 0
    @State var isPresentingBuildView = false
    @State var setPreviewActive = false

    var customSet: CustomSetDurian
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                TabView(selection: $currentCategoryIndex) {
                    ForEach(0..<customSet.round1Len, id: \.self) { categoryIndex in
                        let categoryName = customSet.round1CategoryNames[categoryIndex]
                        let clueSample = customSet.round1Clues[categoryIndex]?.first ?? "NULL CLUE"
                        ZStack {
                            VStack {
                                VStack (spacing: 2) {
                                    Text("\(categoryName.uppercased())")
                                        .id(categoryName)
                                        .font(formatter.font(.bold, fontSize: .small))
                                    Text("for 200")
                                        .font(formatter.font(.bold, fontSize: .small))
                                }
                                .shadow(color: formatter.color(.primaryBG), radius: 10, x: 0, y: 5)
                                Spacer(minLength: 0)
                                Text("\(clueSample.uppercased())")
                                    .id(clueSample)
                                    .font(formatter.korinnaFont(sizeFloat: 20))
                                    .shadow(color: formatter.color(.primaryBG), radius: 0, x: 2, y: 2)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(5)
                                    .padding(35)
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .frame(minHeight: 280, maxHeight: 300)
                        .background(formatter.gradient(.primaryAccent))
                        .opacity(currentCategoryIndex == categoryIndex ? 1 : 0.5)
                        .cornerRadius(5)
                        .scaleEffect(currentCategoryIndex == categoryIndex ? 1 : 0.95)
                        .onTapGesture {
                            selectSet(customSet: customSet)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(minHeight: 280, maxHeight: 300)
                ZStack {
                    HStack (spacing: 10) {
                        // Like button icon
                        Button {
                            formatter.hapticFeedback(style: .medium, intensity: .strong)
                        } label: {
                            Image(systemName: "heart")
                        }
                        Image(systemName: "paperplane")
                        Spacer()
                        Button(action: {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            isPresentingBuildView.toggle()
                            buildVM.edit(customSet: customSet)
                        }, label: {
                            ZStack {
                                Text("Edit")
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .font(formatter.font(fontSize: .small))
                                    .padding(.horizontal, 20)
                                    .frame(height: 35)
                                    .background(formatter.color(.primaryFG))
                                    .cornerRadius(5)
                                NavigationLink (isActive: $isPresentingBuildView) {
                                    MobileBuildView()
                                } label: { EmptyView() }
                                    .hidden()
                            }
                        })
                        Button(action: {
                            formatter.setAlertSettings(alertAction: {
                                buildVM.deleteSet(customSet: customSet)
                                gamesVM.customSets.removeAll(where: { $0.id == customSet.id })
                            }, alertTitle: "Are You Sure?", alertSubtitle: "You're about to delete your set named \"\(customSet.title)\" — deleting a set is irreversible.", hasCancel: true, actionLabel: "Yes, delete my set")
                        }, label: {
                            Image(systemName: "trash")
                        })
                    }
                    HStack (spacing: 5) {
                        ForEach(0..<customSet.round1Len, id: \.self) { i in
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(formatter.color(currentCategoryIndex == i ? .highContrastWhite : .lowContrastWhite))
                        }
                    }
                }
                .font(.system(size: 22))
                .padding(10)
                HStack (alignment: .top, spacing: 10) {
                    ZStack {
                        // Initials user symbol
                        Text("\(exploreVM.getInitialsFromUserID(userID: customSet.userID))")
                            .font(formatter.font(.boldItalic, fontSize: .small))
                            .frame(width: 40, height: 40)
                            .background(formatter.color(.primaryAccent))
                            .clipShape(Circle())
                    }
                    Button {
                        selectSet(customSet: customSet)
                    } label: {
                        VStack (alignment: .leading, spacing: 5) {
                            HStack (spacing: 2) {
                                if !customSet.isPublic {
                                    Image(systemName: "lock.fill")
                                        .font(formatter.iconFont(.small))
                                        .offset(x: -2, y: -1)
                                }
                                Text(customSet.title.trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(formatter.fontFloat(.bold, sizeFloat: 18))
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                            }
                            HStack {
                                Text("\(customSet.numLikes) \(customSet.numLikes == 1 ? "like" : "likes")")
                                    .font(formatter.font(.regular))
                                Circle()
                                    .frame(width: 5, height: 5)
                                Text("\(customSet.hasTwoRounds ? "2 rounds" : "1 round"), \(customSet.numClues) clues")
                                    .font(formatter.font(.regular))
                            }
                            HStack {
                                Text("\(exploreVM.getUsernameFromUserID(userID: customSet.userID))")
                                    .font(formatter.font(.regular))
                                    .lineLimit(1)
                                Circle()
                                    .frame(width: 5, height: 5)
                                Text("\(customSet.numPlays) \(customSet.numPlays == 1 ? "play" : "plays")")
                                Circle()
                                    .frame(width: 5, height: 5)
                                Text("\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
                            }
                            .font(formatter.font(.regular))
                            .foregroundColor(formatter.color(.lowContrastWhite))
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            
            NavigationLink(destination: MobileGamePreviewView(),
                           isActive: $setPreviewActive,
                           label: { EmptyView() }).hidden()
        }
        .frame(maxWidth: .infinity)
    }
    
    func selectSet(customSet: CustomSetDurian) {
        setPreviewActive.toggle()
        formatter.hapticFeedback(style: .light)
        gamesVM.getCustomSetData(customSet: customSet)
        participantsVM.resetScores()
    }
}

struct MobileMyCustomSetCellView2: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var expandedSetID: String
    
    @State var isPresentingBuildView = false
    @State var setPreviewActive = false
    
    var isInUserView = false
    var customSet: CustomSetDurian
    var setID: String {
        return customSet.id ?? "NID"
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack (spacing: 2) {
                if !customSet.isPublic {
                    Image(systemName: "lock.fill")
                        .font(formatter.iconFont(.small))
                        .offset(x: -2, y: -1)
                }
                Text(customSet.title)
                    .font(formatter.font(fontSize: .mediumLarge))
                    .lineLimit(1)
                Spacer()
            }
            if !customSet.description.isEmpty {
                Text(customSet.description)
                    .font(formatter.font(.regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            HStack {
                Text("\(customSet.hasTwoRounds ? "2 rounds" : "1 round"), \(customSet.numClues) clues")
                Circle()
                    .frame(width: 5, height: 5)
                Text("\(customSet.numPlays) play" + "\(customSet.numPlays == 1 ? "" : "s")")
                Circle()
                    .frame(width: 5, height: 5)
                Text("\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
            }
            .font(formatter.font(.regular))
            .foregroundColor(formatter.color(.lowContrastWhite))
            
            if expandedSetID == setID {
                HStack (spacing: 5) {
                    Button {
                        setPreviewActive.toggle()
                        formatter.hapticFeedback(style: .light)
                        gamesVM.reset()
                        gamesVM.getCustomData(customSet: customSet)
                        participantsVM.resetScores()
                    } label: {
                        ZStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(formatter.color(.primaryBG))
                                .font(formatter.iconFont(.small))
                                .frame(width: 45, height: 45)
                                .background(formatter.color(.highContrastWhite))
                                .cornerRadius(5)
                            NavigationLink(destination: GameBoardView()
                                .navigationBarTitle("Set Preview", displayMode: .inline),
                                           isActive: $setPreviewActive,
                                           label: { EmptyView() }).hidden()
                        }
                    }

                    Button(action: {
                        formatter.hapticFeedback(style: .soft, intensity: .strong)
                        isPresentingBuildView.toggle()
                        buildVM.edit(customSet: customSet)
                    }, label: {
                        ZStack {
                            Text("Edit")
                                .foregroundColor(formatter.color(.highContrastWhite))
                                .font(formatter.font(fontSize: .medium))
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .frame(height: 45)
                                .background(formatter.color(.primaryAccent))
                                .cornerRadius(5)
                            NavigationLink (isActive: $isPresentingBuildView) {
                                MobileBuildView()
                            } label: { EmptyView() }
                                .hidden()
                        }
                    })
                    Button(action: {
                        formatter.setAlertSettings(alertAction: {
                            buildVM.deleteSet(customSet: customSet)
                        }, alertTitle: "Are You Sure?", alertSubtitle: "You're about to delete your set named \"\(customSet.title)\" — deleting a set is irreversible.", hasCancel: true, actionLabel: "Yes, delete my set")
                    }, label: {
                        Text("Delete")
                            .foregroundColor(formatter.color(.red))
                            .font(formatter.font(fontSize: .medium))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .background(formatter.color(.primaryFG))
                            .cornerRadius(5)
                    })
                }
            }
        }
        .padding(.horizontal, 15).padding(.vertical, 20)
        .background(formatter.color(expandedSetID == setID ? .secondaryFG : .primaryFG))
        .contentShape(Rectangle())
        .onTapGesture {
            formatter.hapticFeedback(style: .rigid, intensity: .weak)
            expandedSetID = setID
        }
    }
}
