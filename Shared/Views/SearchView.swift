//
//  SearchView.swift
//  Trivio
//
//  Created by David Chen on 3/10/21.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowingSearchView: Bool
    
    var seasonEpGrid = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        Color("MainBG")
            .edgesIgnoringSafeArea(.all)
        ZStack {
            VStack (alignment: .leading) {
                HStack {
                    Button(action: {
                        isShowingSearchView.toggle()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(formatter.deviceType == .iPad ? .largeTitle : .title2)
                    })
                    Text("Search")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                    Image(systemName: "checkmark.circle.fill")
                        .font(formatter.deviceType == .iPad ? .largeTitle : .title2)
                        .foregroundColor(Color.green.opacity(!searchVM.searchPending ? 1 : 0.2))
                }
                HStack {
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                        Image(systemName: "magnifyingglass")
                        TextField("Search a category (must be an exact match)", text: $searchVM.searchItem, onCommit: {
                            searchVM.resetSearchLimit()
                            searchVM.searchAndPull()
                            gamesVM.previewViewShowing = false
                        })
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                self.searchVM.clearSearch()
                            }
                    }
                    .font(formatter.customFont(iPadSize: 20))
                    .padding(.vertical, formatter.shrink(iPadSize: 10)).padding(.horizontal, formatter.shrink(iPadSize: 15))
                    .background(Color.gray.opacity(0.3))
                    .accentColor(.white)
                    .clipShape(Capsule())
                    Button {
                        searchVM.resetSearchLimit()
                        searchVM.searchAndPull()
                        gamesVM.previewViewShowing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("SEARCH")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .padding(.vertical, 5).padding(.horizontal, 10)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(formatter.cornerRadius(5))
                    }
                }
                if searchVM.hasSearch && searchVM.gameIDs.count == 0 {
                    Text("No Matches Found")
                        .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                }
                VStack (alignment: .leading) {
                    if searchVM.searchPending {
                        HStack {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        if searchVM.games.count > 0 {
                            Text("Found \(searchVM.gameIDs.count) matches")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 25))
                            if formatter.deviceType == .iPad {
                                JeopardyGamesView(showingGames: true, games: searchVM.games)
                            } else {
                                if gamesVM.previewViewShowing {
                                    GamePreviewView(searchQuery: searchVM.capSplit)
                                } else {
                                    JeopardyGamesView(showingGames: true, games: searchVM.games)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}
