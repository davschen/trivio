//
//  SummaryView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/8/21.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            Text("Summary")
                .font(formatter.font(fontSize: .extraLarge))
                .foregroundColor(formatter.color(.highContrastWhite))
            SummaryPreviewView()
        }
    }
    
    struct SummaryPreviewView: View {
        @EnvironmentObject var formatter: MasterHandler
        @EnvironmentObject var gamesVM: GamesViewModel
        @EnvironmentObject var participantsVM: ParticipantsViewModel
        @EnvironmentObject var profileVM: ProfileViewModel
        @EnvironmentObject var reportVM: ReportViewModel
        
        var body: some View {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (spacing: 25) {
                    VStack (alignment: .leading) {
                        Button(action: {
                            profileVM.menuSelectedItem = "My Sets"
                        }, label: {
                            HStack {
                                Text("My Sets")
                                    .font(formatter.font(fontSize: .large))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .padding([.horizontal, .top], 20)
                        })
                        
                        if gamesVM.customSets.count > 0 {
                            ScrollView (.horizontal, showsIndicators: false) {
                                HStack (spacing: 20) {
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                    ForEach(gamesVM.customSets, id: \.self) { set in
                                        CustomSetCellView(set: set, isMine: true)
                                            .frame(width: 400)
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
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                }
                                .padding(5)
                                .padding(.bottom)
                            }
                        } else {
                            EmptySummaryView(label: "Nothing yet! When you make a set, it???ll show up here.")
                        }
                    }
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    
                    VStack (alignment: .leading) {
                        Button(action: {
                            profileVM.menuSelectedItem = "My Drafts"
                        }, label: {
                            HStack {
                                Text("My Drafts")
                                    .font(formatter.font(fontSize: .large))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .padding([.horizontal, .top], 20)
                        })
                        if profileVM.drafts.count > 0 {
                            ScrollView (.horizontal, showsIndicators: false) {
                                HStack (spacing: 20) {
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                    ForEach(profileVM.drafts, id: \.self) { draft in
                                        DraftCellView(draft: draft)
                                            .frame(width: 300)
                                    }
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                }
                                .padding(.bottom)
                            }
                        } else {
                            EmptySummaryView(label: "If you save a draft, you can find it here.")
                        }
                    }
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    
                    VStack (alignment: .leading) {
                        Button(action: {
                            profileVM.menuSelectedItem = "Past Games"
                        }, label: {
                            HStack {
                                Text("Past Games")
                                    .font(formatter.font(fontSize: .large))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .padding([.horizontal, .top], 20)
                        })
                        
                        if reportVM.allGames.count > 0 {
                            ScrollView (.horizontal, showsIndicators: false) {
                                HStack (spacing: 20) {
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                    ForEach(reportVM.allGames, id: \.self) { game in
                                        PastGamePreviewView(game: game)
                                    }
                                    Spacer()
                                        .frame(width: 0, height: 0)
                                }
                                .padding(.bottom)
                            }
                        } else {
                            EmptySummaryView(label: "Once you play a game, the report summary will be found here.")
                        }
                    }
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                    
                    Spacer(minLength: 15)
                }
            }
        }
        
        func selectSet(set: CustomSet) {
            guard let setID = set.id else { return }
            gamesVM.getCustomData(setID: setID)
            gamesVM.previewViewShowing = true
            gamesVM.setEpisode(ep: setID)
            gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
            participantsVM.resetScores()
            profileVM.menuSelectedItem = "My Sets"
        }
    }
}

struct PastGamePreviewView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    let game: Report
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            HStack (spacing: 15) {
                Text("\(reportVM.dateFormatter.string(from: game.date))")
                    .font(formatter.font(.bold))
                RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 15)
                Text("\(reportVM.timeFormatter.string(from: game.date))")
                    .font(formatter.font(.regular))
            }
            .foregroundColor(formatter.color(.highContrastWhite))
            ScrollView (.horizontal) {
                HStack (spacing: 15) {
                    ForEach(game.getNames(), id: \.self) { name in
                        Text(name.uppercased())
                            .font(formatter.font())
                            .foregroundColor(formatter.color(.secondaryAccent))
                    }
                }
            }
            Button(action: {
                gamesVM.menuChoice = .game
                if game.episode_played.contains("game_id") {
                    gamesVM.getEpisodeData(gameID: game.episode_played)
                } else {
                    gamesVM.getCustomData(setID: game.episode_played)
                }
                
            }, label: {
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 15))
                    Text("\(reportVM.getGameName(from: game.episode_played))")
                        .font(formatter.font())
                }
                .foregroundColor(formatter.color(.primaryFG))
                .padding()
                .frame(maxWidth: .infinity)
                .background(formatter.color(.highContrastWhite))
                .cornerRadius(5)
            })
        }
        .padding()
        .frame(width: 400)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
    }
}

struct EmptySummaryView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    let label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(formatter.font(.regularItalic))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
        .padding([.horizontal, .bottom], 20)
    }
}
