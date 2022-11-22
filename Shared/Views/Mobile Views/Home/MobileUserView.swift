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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack (spacing: 15) {
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
                .padding(.bottom, 5)
                
                VStack (alignment: .leading, spacing: 3) {
                    ForEach(exploreVM.userResults, id: \.self) { customSet in
                        MobileUserCustomSetCellView(customSet: customSet)
                    }
                }
            }
            .padding(.bottom, 25)
        }
        .withBackButton()
        .withBackground()
        .edgesIgnoringSafeArea(.bottom)
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

