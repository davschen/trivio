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
                        case .clue:
                            MobileTrivioLiveClueView()
                        default:
                            // Display is set to board by default
                            MobileLiveGameBoardView()
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

struct MobileTrivioLiveClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        if gamesVM.currentSelectedClue.isWVC && !gamesVM.clueMechanics.wvcWagerMade {
            MobileLiveDuplexWagerView()
        } else {
            MobileLiveClueResponseView(progressGame: progressGame)
                .transition(AnyTransition.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.2))
            if !profileVM.myUserRecords.hasShownSwipeToDismissClue {
                MobileClueDismissTutorialView()
            }
        }
    }
    
    func progressGame() {
        formatter.stopSpeaker()
        gamesVM.progressGame()
        if !profileVM.myUserRecords.hasShownHeldClueCell {
            formatter.setAlertSettings(alertAction: {
                profileVM.updateMyUserRecords(fieldName: "hasShownHeldClueCell", newValue: true)
                profileVM.myUserRecords.hasShownHeldClueCell = true
            }, alertType: .tip, alertTitle: "Some advice", alertSubtitle: "If you'd like to bring back a clue, just hold down on the empty grid cell for a few seconds", hasCancel: false, actionLabel: "Got it")
        }
        participantsVM.progressGame(gameHasTwoRounds: gamesVM.customSet.hasTwoRounds)
    }
}

struct MobileLiveDuplexWagerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @State var questionIsSelected = false
    
    var maxScore: Int {
        return gamesVM.gamePhase == .round1 ? 1000 : 2000
    }
    
    var body: some View {
        VStack (spacing: 15) {
            VStack {
                Spacer()
                VStack (spacing: 10) {
                    Text(gamesVM.currentSelectedClue.categoryString.uppercased())
                        .font(formatter.font(fontSize: .medium))
                    Text("WAGER-VALUED CLUE")
                        .font(formatter.fontFloat(sizeFloat: 35))
                        .frame(maxWidth: .infinity)
                    Text("Waiting for \(gamesVM.liveGamePlayers.first(where: { $0.id == gamesVM.liveGameCustomSet.currentPlayerId } )?.nickname ?? "NULL") to enter a wager...")
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

struct MobileLiveClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var gamesVM: GamesViewModel

    @State var hasWaited = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progressGame: () -> Void
    var isDisplayingLandscapeMode: Bool = false
    
    private var currentLiveClue: Clue {
        return Clue(liveGameCustomSet: gamesVM.liveGameCustomSet)
    }
    
    private var clueAppearance: ClueAppearance {
        return ClueAppearance(rawValue: UserDefaults.standard.string(forKey: "clueAppearance") ?? "classic") ?? .classic
    }
    
    private var readingSpeedFloat: Double {
        return Double(100 * (UserDefaults.standard.value(forKey: "speechSpeed") as? Float ?? 0.5) / 2)
    }
    
    var body: some View {
        ZStack {
            VStack {
                MobileClueCountdownTimerView(timeElapsed: $gamesVM.clueMechanics.timeElapsed)
                VStack (alignment: .leading, spacing: 0) {
                    MobileClueHeaderView(progressGame: progressGame)
                    VStack {
                        Text(currentLiveClue.clueString.uppercased())
                            .font(formatter.korinnaFont(sizeFloat: 20))
                            .shadow(color: formatter.color(.primaryBG), radius: 0, x: 1, y: 2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .id(gamesVM.currentSelectedClue.clueString)
                            .lineSpacing(5)
                            .padding(.bottom, gamesVM.clueMechanics.showResponse ? 5 : 0)
                        if LiveGameDisplay(from: gamesVM.liveGameCustomSet.currentGameDisplay) == .response {
                            Text(currentLiveClue.responseString.uppercased())
                                .font(formatter.korinnaFont(sizeFloat: 20))
                                .shadow(color: formatter.color(.primaryBG), radius: 0, x: 1, y: 2)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .foregroundColor(formatter.color(gamesVM.currentSelectedClue.isTripleStumper ? .red : .secondaryAccent))
                                .id(gamesVM.currentSelectedClue.responseString)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding([.horizontal, .bottom])
                }
                .background(formatter.color(gamesVM.clueMechanics.timeElapsed >= gamesVM.clueMechanics.numCountdownSeconds ? .primaryFG : .primaryAccent))
                .cornerRadius(10)
            }
        }
        .onReceive(timer) { time in
            let timeElapsed = gamesVM.clueMechanics.timeElapsed
            if timeElapsed > gamesVM.clueMechanics.numCountdownSeconds {
                timer.upstream.connect().cancel()
            } else if (formatter.speaker.volume == 0) && !hasWaited {
                let secondsToWait = Double(gamesVM.currentSelectedClue.clueString.count) / readingSpeedFloat
                if gamesVM.clueMechanics.timeElapsed < -secondsToWait {
                    gamesVM.clueMechanics.setTimeElapsed(newValue: 0)
                    hasWaited = true
                } else {
                    gamesVM.clueMechanics.setTimeElapsed(newValue: timeElapsed - 1)
                }
            } else if !formatter.speaker.isSpeaking && timeElapsed < gamesVM.clueMechanics.numCountdownSeconds {
                gamesVM.clueMechanics.setTimeElapsed(newValue: timeElapsed + 1)
            }
        }
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
