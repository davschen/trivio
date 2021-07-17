//
//  GamePickerView.swift
//  Trivio
//
//  Created by David Chen on 2/8/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct GamePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @State var audioPlayer: AVAudioPlayer!
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            VStack {
                GamePickerSearchBarView()
                if !searchVM.isShowingExpandedView && !searchVM.isShowingSearchView {
                    ClassicGamePickerView()
                } else if searchVM.isShowingSearchView && !searchVM.isShowingExpandedView {
                    SearchView()
                }
            }
        }
        .padding(30)
    }
}

struct GamePickerSearchBarView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                TextField("Search games", text: $searchVM.searchItem, onEditingChanged: { focused in
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
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        .padding(.bottom, 20)
    }
}

struct ClassicGamePickerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    
    var body: some View {
        HStack {
            if formatter.deviceType == .iPad {
                ScrollView (.vertical, showsIndicators: false) {
                    SeasonsListView()
                }
                .frame(width: UIScreen.main.bounds.width * 0.15)
                .padding(.trailing, 30)
            }
            VStack {
                if formatter.deviceType == .iPhone {
                    HStack {
                        Button(action: {
                            searchVM.isShowingSearchView.toggle()
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: formatter.padding(size: 30)))
                        })
                        Text("Seasons")
                            .font(MasterHandler().customFont(weight: "Bold", iPadSize: 50))
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack (spacing: 3) {
                                SeasonsListView()
                            }
                        }
                    }
                    Spacer()
                }
                if formatter.deviceType == .iPad {
                    JeopardyGamesView(showingGames: false, gamePreviews: gamesVM.gamePreviews)
                } else {
                    if gamesVM.previewViewShowing {
                        GamePreviewView()
                    } else {
                        JeopardyGamesView(showingGames: false, gamePreviews: gamesVM.gamePreviews)
                    }
                }
            }
        }
    }
}

struct SeasonsListView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 5) {
            ForEach(gamesVM.seasonFolders, id: \.self) { folder in
                let folderID = folder.id ?? "NID"
                ZStack {
                    Text(folder.title)
                        .font(formatter.font(fontSize: .mediumLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .padding(.vertical, 5)
                .background(formatter.color(.secondaryAccent).opacity(gamesVM.selectedSeason == folderID ? 1 : 0))
                .cornerRadius(5)
                .onTapGesture {
                    self.gamesVM.getEpisodes(seasonID: folderID)
                    self.gamesVM.setSeason(folder: folder)
                    self.gamesVM.setEpisode(ep: "")
                    self.gamesVM.clearAll()
                    self.gamesVM.previewViewShowing = false
                }
            }
        }
    }
}

struct JeopardyGamesView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var formatter: MasterHandler
    var showingGames = true
    var gamePreviews = [GamePreview]()
    var games = [Game]()
    
    var body: some View {
        if (showingGames ? !searchVM.games.isEmpty : !gamesVM.selectedSeason.isEmpty) {
            GeometryReader { geometry in
                VStack (alignment: .leading, spacing: 5) {
                    if !showingGames {
                        Text(gamesVM.currentSeason.title)
                            .font(formatter.font(fontSize: .large))
                    }
                    if gamesVM.previewViewShowing {
                        GamePreviewView(searchQuery: searchVM.capSplit)
                    }
                    VStack (alignment: .leading, spacing: 0) {
                        ScrollView (.vertical) {
                            VStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                                if showingGames {
                                    ForEach(games, id: \.self) { gamePreview in
                                        let gamePreviewID = gamePreview.id ?? "NID"
                                        HStack {
                                            Text("\(gamePreview.title)")
                                                .frame(width: geometry.size.width * 0.3, alignment: .leading)
                                            Spacer()
                                            Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                        }
                                        .padding(formatter.padding())
                                        .font(MasterHandler().customFont(weight: "Bold", iPadSize: 20))
                                        .lineLimit(1)
                                        .foregroundColor(formatter.color(beenPlayed(gameID: gamePreviewID) ? .lowContrastWhite : .highContrastWhite))
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .background(formatter.color(.primaryAccent).opacity(gamesVM.selectedEpisode == gamePreviewID ? 1 : 0))
                                        .cornerRadius(formatter.cornerRadius(5))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            self.gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            self.gamesVM.setEpisode(ep: gamePreviewID)
                                            self.gamesVM.previewViewShowing = true
                                            self.participantsVM.resetScores()
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
                                        HStack {
                                            Text("\(gamePreview.title)")
                                                .frame(width: geometry.size.width * 0.3, alignment: .leading)
                                            Text("\(gamePreview.contestants)")
                                                .frame(width: geometry.size.width * 0.5, alignment: .leading)
                                            Spacer()
                                            Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                        }
                                        .padding(formatter.padding())
                                        .font(formatter.font())
                                        .foregroundColor(formatter.color(beenPlayed(gameID: gamePreviewID) ? .lowContrastWhite : .highContrastWhite))
                                        .lineLimit(1)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .background(formatter.color(.primaryAccent).opacity(gamesVM.selectedEpisode == gamePreviewID ? 1 : 0))
                                        .cornerRadius(formatter.cornerRadius(5))
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            self.gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            self.gamesVM.setEpisode(ep: gamePreviewID)
                                            self.gamesVM.previewViewShowing = true
                                            self.participantsVM.resetScores()
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
            EmptyListView(label: showingGames ? "No games to show" : "You haven't picked a season yet. Pick a season above to browse games.")
        }
    }
    
    func beenPlayed(gameID: String) -> Bool {
        return gamesVM.playedGames.contains(gameID)
    }
}
