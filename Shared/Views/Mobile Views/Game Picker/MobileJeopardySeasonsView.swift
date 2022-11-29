//
//  MobileJeopardySeasonsView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/28/22.
//

import Foundation
import SwiftUI

struct MobileJeopardySeasonsView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var episodesViewActive = false
    @State var seasonString = ""
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack (spacing: 10) {
                    Spacer(minLength: 20)
                    VStack (alignment: .leading, spacing: 3) {
                        ForEach(gamesVM.jeopardySeasons, id: \.self) { season in
                            HStack {
                                Text("\(season.title)")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.horizontal)
                            .frame(height: 80)
                            .background(formatter.color(.primaryFG))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard let seasonID = season.id else { return }
                                gamesVM.getEpisodes(seasonID: seasonID)
                                self.seasonString = season.title
                                episodesViewActive.toggle()
                            }
                        }
                    }
                }
                .padding(.bottom, 25)
            }
            .withBackButton()
            .withBackground()
            .edgesIgnoringSafeArea(.bottom)
            
            NavigationLink(destination: MobileJeopardySeasonEpisodesView(seasonString: seasonString),
                           isActive: $episodesViewActive,
                           label: { EmptyView() }).isDetailLink(false).hidden()
        }
    }
}

struct MobileJeopardySeasonEpisodesView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var setPreviewActive = false
    
    let seasonString: String
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack (spacing: 10) {
                    Spacer(minLength: 20)
                    VStack (alignment: .leading, spacing: 3) {
                        ForEach(gamesVM.gamePreviews, id: \.self) { preview in
                            HStack {
                                VStack (alignment: .leading, spacing: 10) {
                                    Text("\(preview.title)")
                                    Text("\(preview.contestants)")
                                        .font(formatter.font(.regular))
                                        .foregroundColor(formatter.color(.lowContrastWhite))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.horizontal)
                            .frame(height: 100)
                            .background(formatter.color(.primaryFG))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectSet(jeopardySetPreview: preview)
                                setPreviewActive.toggle()
                            }
                        }
                    }
                }
                .padding(.bottom, 25)
            }
            .withBackButton()
            .withBackground()
            .edgesIgnoringSafeArea(.bottom)
            
            NavigationLink(destination: MobileGameSettingsView()
                .navigationBarTitle("Set Preview", displayMode: .inline),
                           isActive: $setPreviewActive,
                           label: { EmptyView() }).hidden()
        }
        .navigationBarTitle("\(seasonString)", displayMode: .inline)
    }
    
    func selectSet(jeopardySetPreview: JeopardySetPreview) {
        formatter.hapticFeedback(style: .light)
        guard let gameID = jeopardySetPreview.id else { return }
        gamesVM.reset()
        gamesVM.getEpisodeData(gameID: gameID)
        participantsVM.resetScores()
    }
}
