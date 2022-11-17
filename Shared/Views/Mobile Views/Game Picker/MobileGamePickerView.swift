//
//  MobileGamePickerView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import AVFoundation
import Shimmer

struct MobileGamePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            VStack {
                MobileGamePickerSearchBarView()
                if !searchVM.isShowingExpandedView && !searchVM.isShowingSearchView {
                    MobileClassicGamePickerView()
                } else if searchVM.isShowingSearchView && !searchVM.isShowingExpandedView {
                    MobileSearchView()
                }
            }
            .redacted(reason: gamesVM.loadingGame ? .placeholder : [])
            .shimmering(active: gamesVM.loadingGame)
        }
        .padding(.horizontal)
    }
}

struct MobileGamePickerSearchBarView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        VStack {
            HStack {
                if searchVM.isShowingExpandedView {
                    Button {
                        searchVM.isShowingExpandedView.toggle()
                        formatter.resignKeyboard()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .bold))
                    }
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .bold))
                }
                TextField("Search games by category", text: $searchVM.searchItem, onEditingChanged: { focused in
                    if focused {
                        searchVM.isShowingExpandedView = true
                    } else {
                        searchVM.isShowingExpandedView = false
                    }
                }, onCommit: {
                    if searchVM.searchItem.isEmpty {
                        searchVM.isShowingSearchView = false
                        searchVM.isShowingExpandedView = false
                    } else {
                        searchVM.searchAndPull()
                        searchVM.isShowingSearchView = true
                    }
                })
                .font(formatter.font())
                .accentColor(formatter.color(.secondaryAccent))
                .foregroundColor(formatter.color(.highContrastWhite))
                if !searchVM.searchItem.isEmpty {
                    Button {
                        searchVM.searchItem.removeAll()
                        searchVM.isShowingExpandedView = false
                        searchVM.isShowingSearchView = false
                        formatter.resignKeyboard()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 10)
                    }
                }
            }
            if searchVM.isShowingExpandedView {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(.vertical, 5)
                
                ScrollView (.vertical) {
                    VStack {
                        ForEach(searchVM.lastSearches, id: \.self) { search in
                            if searchVM.searchItem.isEmpty || search.search.contains(searchVM.searchItem) {
                                HStack {
                                    Spacer()
                                        .frame(width: 15)
                                    Text("\(search.search)")
                                        .font(formatter.font())
                                    Spacer()
                                    Button {
                                        searchVM.removeFromLastSearches(search: search)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 20, weight: .light))
                                    }
                                }
                                .foregroundColor(formatter.color(.mediumContrastWhite))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    searchVM.searchItem = search.search
                                    searchVM.isShowingExpandedView.toggle()
                                    searchVM.isShowingSearchView = true
                                    searchVM.searchAndPull()
                                    formatter.resignKeyboard()
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .foregroundColor(formatter.color(.lowContrastWhite))
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(5)
        .padding(.bottom, 5)
    }
}

struct MobileClassicGamePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        VStack {
            ScrollView (.horizontal, showsIndicators: false) {
                MobileSeasonsListView()
            }
            VStack {
                MobileJeopardyGamesView(showingGames: false, gamePreviews: gamesVM.gamePreviews)
            }
        }
    }
}

struct MobileSeasonsListView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        HStack (spacing: 5) {
            ForEach(gamesVM.seasonFolders, id: \.self) { season in
                let seasonID = season.id ?? "NID"
                ZStack {
                    Text(season.title)
                        .font(formatter.font(fontSize: .mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .padding(.vertical, 5)
                .background(formatter.color(.secondaryAccent).opacity(gamesVM.selectedSeason == seasonID ? 1 : 0))
                .cornerRadius(5)
                .onTapGesture {
                    formatter.hapticFeedback(style: .medium, intensity: .strong)
                    gamesVM.getEpisodes(seasonID: seasonID)
                    gamesVM.setSeason(folder: season)
                    gamesVM.setCustomSetID(ep: "")
                    gamesVM.clearAll()
                    gamesVM.previewViewShowing = false
                }
            }
        }
    }
}

struct MobileJeopardyGamesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var showingGames = true
    var gamePreviews = [GamePreview]()
    var games = [Game]()
    
    var body: some View {
        if (showingGames ? !searchVM.games.isEmpty : !gamesVM.selectedSeason.isEmpty) {
            GeometryReader { geometry in
                VStack (alignment: .leading, spacing: 15) {
                    MobileGamePreviewView(categories: gamesVM.tidyCustomSet.round1Cats)
                    MobileGamePreviewView(categories: gamesVM.tidyCustomSet.round2Cats)
                    VStack (alignment: .leading, spacing: 0) {
                        ScrollView (.vertical) {
                            VStack {
                                if showingGames {
                                    ForEach(games, id: \.self) { gamePreview in
                                        let gamePreviewID = gamePreview.id ?? "NID"
                                        HStack {
                                            Text("\(gamePreview.title)")
                                            Spacer()
                                            Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                                .font(formatter.font(.regular))
                                        }
                                        .padding(formatter.padding())
                                        .font(formatter.font())
                                        .lineLimit(1)
                                        .foregroundColor(formatter.color(beenPlayed(gameID: gamePreviewID) ? .lowContrastWhite : .highContrastWhite))
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .background(formatter.color(.primaryAccent).opacity(gamesVM.customSet.id == gamePreviewID ? 1 : 0))
                                        .cornerRadius(5)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            formatter.hapticFeedback(style: .medium, intensity: .strong)
                                            gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            gamesVM.setCustomSetID(ep: gamePreviewID)
                                            gamesVM.previewViewShowing = true
                                            participantsVM.resetScores()
                                        }
                                        .id(UUID())
                                    }
                                    if searchVM.gameIDs.count >= 100 {
                                        Button(action: {
                                            searchVM.changeSearchLimit(increase: true)
                                        }, label: {
                                            HStack {
                                                Text("Show More")
                                                Image(systemName: "plus")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(formatter.padding())
                                            .font(formatter.font())
                                            .foregroundColor(formatter.color(.highContrastWhite))
                                            .background(formatter.color(.primaryAccent))
                                            .cornerRadius(5)
                                        })
                                    }
                                } else {
                                    ForEach(gamePreviews, id: \.self) { gamePreview in
                                        let gamePreviewID = gamePreview.id ?? "NID"
                                        VStack (alignment: .leading, spacing: 10) {
                                            HStack {
                                                Text("\(gamePreview.title)")
                                                    .font(formatter.font(fontSize: .regular))
                                                Spacer()
                                                Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                            }
                                            Text("\(gamePreview.contestants)")
                                        }
                                        .font(formatter.font(.regular, fontSize: .small))
                                        .foregroundColor(formatter.color(beenPlayed(gameID: gamePreviewID) ? .lowContrastWhite : .highContrastWhite))
                                        .lineLimit(1)
                                        .padding(10)
                                        .background(formatter.color(.primaryAccent).opacity(gamesVM.customSet.id == gamePreviewID ? 1 : 0))
                                        .cornerRadius(5)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            formatter.hapticFeedback(style: .medium, intensity: .strong)
                                            gamesVM.setCustomSetID(ep: gamePreviewID)
                                            gamesVM.previewViewShowing = true
                                            gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            participantsVM.resetScores()
                                        }
                                        .id(UUID())
                                    }
                                }
                            }
                        }
                        .cornerRadius(formatter.cornerRadius(5))
                    }
                }
            }
        } else {
            MobileEmptyListView(label: showingGames ? "No games to show" : "You haven't picked a season yet. Pick a season above to browse games.")
        }
    }
    
    func beenPlayed(gameID: String) -> Bool {
        return gamesVM.playedGames.contains(gameID)
    }
}

