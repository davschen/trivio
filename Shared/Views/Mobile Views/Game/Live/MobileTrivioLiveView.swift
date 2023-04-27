//
//  MobileTrivioLiveView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/2/23.
//

import Foundation
import SwiftUI

struct MobileTrivioLiveView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            HStack (spacing: 20) {
                // Variable game display
                ZStack {
                    if let display = LiveGameDisplay(from: gamesVM.liveGameCustomSet.currentGameDisplay) {
                        switch display {
                        case .preWVC:
                            MobileLiveDuplexWagerView()
                        case .preFinalClue:
                            MobileLivePreFinalClueView()
                        default:
                            MobileLiveGameBoardView()
                                .opacity(display == .board ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3))
                            MobileLiveClueView()
                                .offset(y: (display == .clue || display == .response) ? 0 : 1000)
                                .animation(.easeInOut(duration: 0.1))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                MobileLiveGameSideRailView()
            }
            .padding(.top)
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
    }
}

struct MobileLivePreFinalClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack (spacing: 15) {
            VStack {
                Spacer()
                VStack (spacing: 10) {
                    Text("FINAL CLUE CATEGORY")
                        .font(formatter.font(fontSize: .medium))
                    Text(gamesVM.liveGameCustomSet.finalCat.uppercased())
                        .font(formatter.fontFloat(sizeFloat: 35))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Text("Make your wagers!")
                        .font(formatter.font(.regular))
                }
                .padding(25)
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(formatter.color(.primaryAccent))
        .cornerRadius(10)
    }
}

enum LiveGameDisplay {
    case board, clue, response, preWVC, preFinalClue, finalClue, finalResponse, finalStats
    
    init?(from string: String) {
        switch string {
        case "board":
            self = .board
        case "clue":
            self = .clue
        case "response":
            self = .response
        case "preWVC":
            self = .preWVC
        case "preFinalClue":
            self = .preFinalClue
        case "finalClue":
            self = .finalClue
        case "finalResponse":
            self = .finalResponse
        case "finalStats":
            self = .finalStats
        default:
            return nil
        }
    }
}
