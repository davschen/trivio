//
//  MobileSearchView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileSearchView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                if searchVM.hasSearch && searchVM.gameIDs.count == 0 && !searchVM.searchPending {
                    Text("No Matches Found")
                        .font(formatter.font())
                        .frame(maxWidth: .infinity)
                }
                VStack (alignment: .leading) {
                    if searchVM.searchPending {
                        HStack {
                            LoadingView()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        if searchVM.games.count > 0 {
                            if formatter.deviceType == .iPad {
                                Text("Found \(searchVM.gameIDs.count) matches")
                                    .font(formatter.font())
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                MobileJeopardyGamesView(showingGames: true, games: searchVM.games)
                            } else {
                                MobileJeopardyGamesView(showingGames: true, games: searchVM.games)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

