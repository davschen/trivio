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
    @EnvironmentObject var searchVM: SearchViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ParticipantsViewModel
    @State var audioPlayer: AVAudioPlayer!
    @Environment(\.colorScheme) var colorScheme
    @State var isShowingSearchView = false
    
    private var formatter = MasterHandler()
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            if isShowingSearchView {
                SearchView(isShowingSearchView: $isShowingSearchView)
            } else {
                HStack {
                    if formatter.deviceType == .iPad {
                        VStack (alignment: .leading, spacing: 5) {
                            HStack {
                                Button(action: {
                                    isShowingSearchView.toggle()
                                }, label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: MasterHandler().padding(size: 30)))
                                })
                                Text("Seasons")
                                    .font(MasterHandler().customFont(weight: "Bold", iPadSize: 50))
                            }
                            ScrollView (.vertical, showsIndicators: false) {
                                SeasonsListView()
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.2)
                            .padding(.trailing, 5)
                        }
                    }
                    VStack {
                        if formatter.deviceType == .iPhone {
                            HStack {
                                Button(action: {
                                    isShowingSearchView.toggle()
                                }, label: {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: MasterHandler().padding(size: 30)))
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
    }
}

struct SeasonsListView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        ForEach(gamesVM.seasonFolders, id: \.self) { folder in
            let folderID = folder.id ?? "NID"
            ZStack {
                Text(folder.title)
                    .font(MasterHandler().customFont(weight: "Bold", iPadSize: 30))
                    .foregroundColor(Color("MainAccent"))
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .minimumScaleFactor(0.1)
            }
            .frame(maxWidth: .infinity)
            .shadow(color: Color.black.opacity(0.2), radius: 10)
            .padding(10)
            .background(Color.gray.opacity(gamesVM.selectedSeason == folderID ? 1 : 0.3))
            .cornerRadius(formatter.cornerRadius(5))
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
                            .font(MasterHandler().customFont(weight: "Bold", iPadSize: 40))
                    }
                    if !gamesVM.selectedEpisode.isEmpty && formatter.deviceType == .iPad {
                        GamePreviewView()
                    }
                    VStack (alignment: .leading, spacing: 0) {
                        HStack {
                            Text("")
                                .frame(width: geometry.size.width * 0.03, alignment: .leading)
                            Text("TITLE")
                                .tracking(2)
                                .frame(width: geometry.size.width * 0.3, alignment: .leading)
                            if !showingGames {
                                Image(systemName: "person.3")
                                    .frame(width: geometry.size.width * 0.5, alignment: .leading)
                            }
                            Spacer()
                            Image(systemName: "calendar")
                                .frame(width: 70, alignment: .leading)
                        }
                        .font(MasterHandler().customFont(weight: "Medium", iPadSize: 15))
                        .lineLimit(1)
                        .padding(.horizontal)
                        ScrollView (.vertical) {
                            VStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                                if showingGames {
                                    ForEach(games, id: \.self) { gamePreview in
                                        let gamePreviewID = gamePreview.id ?? "NID"
                                        HStack {
                                            Image(systemName: beenPlayed(gameID: gamePreviewID) ? "checkmark.square.fill" : "checkmark.square")
                                                .frame(width: geometry.size.width * 0.03, alignment: .leading)
                                            Text("\(gamePreview.title)")
                                                .frame(width: geometry.size.width * 0.3, alignment: .leading)
                                            Spacer()
                                            Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                        }
                                        .padding(formatter.padding())
                                        .font(MasterHandler().customFont(weight: "Bold", iPadSize: 20))
                                        .lineLimit(1)
                                        .foregroundColor(Color.white)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .background(Color.white.opacity(gamesVM.selectedEpisode == gamePreviewID ? 0.2 : 0))
                                        .background(beenPlayed(gameID: gamePreviewID) ? Color("Darkened") : Color("MainFG"))
                                        .cornerRadius(formatter.cornerRadius(5))
                                        .onTapGesture {
                                            self.gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            self.gamesVM.setEpisode(ep: gamePreviewID)
                                            self.gamesVM.previewViewShowing.toggle()
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
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 15))
                                            .foregroundColor(.white)
                                            .background(Color("MainFG"))
                                            .cornerRadius(5)
                                        })
                                    }
                                } else {
                                    ForEach(gamePreviews, id: \.self) { gamePreview in
                                        let gamePreviewID = gamePreview.id ?? "NID"
                                        HStack {
                                            Image(systemName: beenPlayed(gameID: gamePreviewID) ? "checkmark.square.fill" : "checkmark.square")
                                                .frame(width: geometry.size.width * 0.03, alignment: .leading)
                                            Text("\(gamePreview.title)")
                                                .frame(width: geometry.size.width * 0.3, alignment: .leading)
                                            Text("\(gamePreview.contestants)")
                                                .frame(width: geometry.size.width * 0.5, alignment: .leading)
                                            Spacer()
                                            Text(gamesVM.dateFormatter.string(from: gamePreview.date))
                                        }
                                        .padding(formatter.padding())
                                        .font(MasterHandler().customFont(weight: "Bold", iPadSize: 20))
                                        .lineLimit(1)
                                        .foregroundColor(Color.white)
                                        .padding(.vertical, 5)
                                        .frame(maxWidth: .infinity)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .background(Color.white.opacity(gamesVM.selectedEpisode == gamePreviewID ? 0.2 : 0))
                                        .background(beenPlayed(gameID: gamePreviewID) ? Color("Darkened") : Color("MainFG"))
                                        .cornerRadius(formatter.cornerRadius(5))
                                        .onTapGesture {
                                            self.gamesVM.getEpisodeData(gameID: gamePreviewID)
                                            self.gamesVM.setEpisode(ep: gamePreviewID)
                                            self.gamesVM.previewViewShowing.toggle()
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
