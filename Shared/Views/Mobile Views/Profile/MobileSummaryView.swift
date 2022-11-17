//
//  MobileSummaryView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileSummaryView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var exploreVM: ExploreViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    var body: some View {
        SummaryPreviewView()
            .padding(.horizontal)
    }
    
    struct SummaryPreviewView: View {
        @EnvironmentObject var formatter: MasterHandler
        @EnvironmentObject var gamesVM: GamesViewModel
        @EnvironmentObject var participantsVM: ParticipantsViewModel
        @EnvironmentObject var profileVM: ProfileViewModel
        @EnvironmentObject var reportVM: ReportViewModel
        
        var body: some View {
            ZStack {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack (spacing: 15) {
                        Spacer(minLength: 15)
                        MobileSummaryMySetsView()
                        MobileSummaryMyDraftsView()
                        MobileSummaryPastGamesView()
                        Spacer(minLength: 15)
                    }
                }
            }
        }
    }
}

struct MobileSummaryMySetsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var previewViewActive = false
    @State var selectionViewActive = false
    
    var body: some View {
        VStack (alignment: .leading) {
            ZStack {
                Button(action: {
                    formatter.hapticFeedback(style: .light)
                    profileVM.menuSelectedItem = "My Sets"
                    selectionViewActive.toggle()
                }, label: {
                    HStack {
                        Text("My Sets")
                            .font(formatter.font(fontSize: .large))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(formatter.iconFont())
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding([.horizontal, .top])
                })
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }.hidden()
            }
            
            if gamesVM.customSets.count > 0 {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 15) {
                        Spacer()
                            .frame(width: 0, height: 0)
                        ForEach(gamesVM.customSets, id: \.self) { customSet in
                            ZStack {
                                MobileCustomSetCellView(customSet: customSet)
                                    .frame(width: 300)
                                    .onTapGesture {
                                        if gamesVM.gameInProgress() {
                                            formatter.setAlertSettings(alertAction: {
                                                selectSet(set: customSet)
                                            }, alertTitle: "Cancel current game?", alertSubtitle: "It looks like you have a game in progress. Choosing this one would erase all of your progress.", hasCancel: true, actionLabel: "Yes, choose this game")
                                        } else {
                                            selectSet(set: customSet)
                                        }
                                    }
                                NavigationLink(destination: MobileSetPreviewView()
                                                .navigationBarTitle("Preview", displayMode: .inline),
                                               isActive: $previewViewActive,
                                               label: {}).hidden()
                                NavigationLink(destination: EmptyView()) {
                                    EmptyView()
                                }.hidden()
                            }
                        }
                        Spacer()
                            .frame(width: 0, height: 0)
                    }
                    .padding(.bottom)
                }
            } else {
                MobileEmptySummaryView(label: "Nothing yet! When you make a set, it’ll show up here.")
            }
        }
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
    
    func selectSet(set: CustomSetCherry) {
        formatter.hapticFeedback(style: .light)
        guard let setID = set.id else { return }
        gamesVM.getCustomData(setID: setID)
        gamesVM.gameQueryFromType = gamesVM.menuChoice == .profile ? .profile : .explore
        participantsVM.resetScores()
        previewViewActive = true
    }
}

struct MobileSummaryMyDraftsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State var selectionViewActive = false
    
    var body: some View {
        VStack (alignment: .leading) {
            ZStack {
                Button(action: {
                    formatter.hapticFeedback(style: .light)
                    profileVM.menuSelectedItem = "My Drafts"
                    selectionViewActive.toggle()
                }, label: {
                    HStack {
                        Text("My Drafts")
                            .font(formatter.font(fontSize: .large))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(formatter.iconFont())
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding([.horizontal, .top])
                })
                NavigationLink(destination: MobileDraftsView().withBackButton()
                                .navigationBarTitle("My Drafts", displayMode: .inline),
                               isActive: $selectionViewActive,
                               label: { EmptyView() }).hidden()
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }.hidden()
            }
            
            if profileVM.drafts.count > 0 {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 15) {
                        Spacer()
                            .frame(width: 0, height: 0)
                        ForEach(profileVM.drafts, id: \.self) { draft in
                            MobileDraftCellView(draft: draft)
                                .frame(width: 300)
                        }
                        Spacer()
                            .frame(width: 0, height: 0)
                    }
                    .padding(.bottom)
                }
            } else {
                MobileEmptySummaryView(label: "If you save a draft, you can find it here.")
            }
        }
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
}

struct MobileSummaryPastGamesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var reportVM: ReportViewModel
    
    @State var selectionViewActive = false
    
    var body: some View {
        VStack (alignment: .leading) {
            ZStack {
                Button(action: {
                    formatter.hapticFeedback(style: .light)
                    profileVM.menuSelectedItem = "Past Games"
                    selectionViewActive.toggle()
                }, label: {
                    HStack {
                        Text("Past Games")
                            .font(formatter.font(fontSize: .large))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(formatter.iconFont())
                    }
                    .foregroundColor(formatter.color(.highContrastWhite))
                    .padding([.horizontal, .top])
                })
            }
            
            if reportVM.allGameReports.count > 0 {
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack (spacing: 15) {
                        Spacer()
                            .frame(width: 0, height: 0)
                        ForEach(reportVM.allGameReports, id: \.self) { game in
                            MobilePastGamePreviewView(game: game)
                                .onTapGesture {
                                    formatter.hapticFeedback(style: .light)
                                    selectionViewActive.toggle()
                                    if let gameID = game.id {
                                        reportVM.selectedGameID = gameID
                                    }
                                }
                        }
                        Spacer()
                            .frame(width: 0, height: 0)
                    }
                    .padding(.bottom)
                }
            } else {
                MobileEmptySummaryView(label: "Once you play a game, the report summary will be found here.")
            }
            NavigationLink(destination: MobileReportsView().withBackButton()
                            .navigationBarTitle("Past Games", displayMode: .inline),
                           isActive: $selectionViewActive,
                           label: { EmptyView() }).hidden()
            NavigationLink(destination: EmptyView()) {
                EmptyView()
            }.hidden()
        }
        .background(formatter.color(.primaryFG))
        .cornerRadius(10)
    }
}

struct MobilePastGamePreviewView: View {
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
        .frame(width: 300)
        .background(formatter.color(.secondaryFG))
        .cornerRadius(10)
    }
}

struct MobileEmptySummaryView: View {
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

