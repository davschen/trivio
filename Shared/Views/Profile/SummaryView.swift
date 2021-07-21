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
            Spacer()
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
                        
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack (spacing: 20) {
                                Spacer()
                                    .frame(width: 0, height: 0)
                                ForEach(gamesVM.customSets, id: \.self) { set in
                                    CustomSetCellView(set: set, isMine: true)
                                        .frame(width: 400)
                                        .onTapGesture {
                                            guard let setID = set.id else { return }
                                            gamesVM.getCustomData(setID: setID)
                                            gamesVM.previewViewShowing = true
                                            gamesVM.setEpisode(ep: setID)
                                            participantsVM.resetScores()
                                            profileVM.menuSelectedItem = "My Sets"
                                        }
                                }
                                Spacer()
                                    .frame(width: 0, height: 0)
                            }
                            .padding(5)
                            .padding(.bottom)
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
                    }
                    .background(formatter.color(.primaryFG))
                    .cornerRadius(10)
                }
            }
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
