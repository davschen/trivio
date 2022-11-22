//
//  MobileUserView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileUserView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var showingTags = [String]()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack (alignment: .leading, spacing: 5) {
                    Text("\(exploreVM.selectedUserName)")
                        .font(formatter.font(.bold, fontSize: .mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                    Text("@\(exploreVM.selectedUserUsername)")
                        .font(formatter.font(.regular, fontSize: .medium))
                        .foregroundColor(formatter.color(.highContrastWhite))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 10)
                
                FlexibleView(data: exploreVM.selectedUserTagsDict.keys, spacing: 3, alignment: .leading) { item in
                    HStack (spacing: 0) {
                        Text("#")
                        Text(verbatim: item)
                    }
                    .foregroundColor(formatter.color(unwrappedUserTagBool(item: item) ? .primaryFG : .highContrastWhite))
                    .font(formatter.font(.boldItalic, fontSize: .small))
                    .padding(6)
                    .background(formatter.color(unwrappedUserTagBool(item: item) ? .highContrastWhite : .secondaryFG))
                    .clipShape(Capsule())
                    .padding(.vertical, 2)
                    .onTapGesture {
                        exploreVM.toggleSelectedUserTagsDict(item: item)
                        if unwrappedUserTagBool(item: item) {
                            showingTags.append(item)
                        } else {
                            showingTags = showingTags.filter { $0 != item }
                        }
                    }
                }
                .padding(.leading)
                
                VStack (alignment: .leading, spacing: 3) {
                    ForEach(exploreVM.userResults, id: \.self) { customSet in
                        if showingTags.contains(where: customSet.tags.contains) {
                            MobileUserCustomSetCellView(customSet: customSet)
                        }
                    }
                }
            }
            .padding(.bottom, 25)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    showingTags = exploreVM.selectedUserTagsDict.keys.compactMap { $0 }
                }
            }
        }
        .withBackButton()
        .withBackground()
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func unwrappedUserTagBool(item: String) -> Bool {
        return exploreVM.selectedUserTagsDict[item] ?? false
    }
}

struct MobileUserCustomSetCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel

    @State var setPreviewActive = false
    
    var customSet: CustomSetCherry
    var setID: String {
        return customSet.id ?? "NID"
    }
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading, spacing: 10) {
                HStack (spacing: 4) {
                    Text(customSet.title)
                        .font(formatter.font(fontSize: .mediumLarge))
                    Spacer()
                }
                Text("Tags: \(customSet.tags.map{String($0).lowercased()}.joined(separator: ", "))")
                    .font(formatter.font(.regular))
                    .foregroundColor(formatter.color(.lowContrastWhite))
                HStack {
                    Text("\(customSet.hasTwoRounds ? "2 rounds" : "1 round"), \(customSet.numClues) clues")
                    Circle()
                        .frame(width: 5, height: 5)
                    Text("\(customSet.plays) play" + "\(customSet.plays > 1 ? "s" : "")")
                    Circle()
                        .frame(width: 5, height: 5)
                    Text("\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
                }
                .font(formatter.font(.regular))
                .foregroundColor(formatter.color(.lowContrastWhite))
            }
            .padding(.horizontal, 15).padding(.vertical, 20)
            .background(formatter.color(.primaryFG))
            
            NavigationLink(destination: MobileGameSettingsView()
                .navigationBarTitle("Set Preview", displayMode: .inline),
                           isActive: $setPreviewActive,
                           label: { EmptyView() }).hidden()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectSet(customSet: customSet)
            setPreviewActive.toggle()
        }
    }
    
    func selectSet(customSet: CustomSetCherry) {
        formatter.hapticFeedback(style: .light)
        gamesVM.reset()
        gamesVM.getCustomData(setID: setID)
        gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
        participantsVM.resetScores()
    }
}

