//
//  GameplayView.swift
//  Trivio
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI

struct GameplayView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var clue = ""
    @State var value = ""
    @State var response = ""
    @State var amount = 0
    @State var finalJeopardySelected = false
    @State var unsolved = false
    @State var isDailyDouble = false
    @State var isTripleStumper = false
    @State var allDone = false
    @State var showInfoView = false
    @State var category = ""
    
    var body: some View {
        VStack (spacing: 10) {
            GameplayHeaderView(showInfoView: $showInfoView)
                .offset(y: 10)
            PlayersView()
            ZStack {
                ZStack {
                    if gamesVM.gamePhase == .finalTrivio && gamesVM.finalTrivioStage != .notBegun {
                        FinalTrivioView()
                    } else {
                        if gamesVM.gameplayDisplay == .grid {
                            GameGridView(clue: $clue, value: $value, response: $response, amount: $amount, unsolved: $unsolved, isDailyDouble: $isDailyDouble, isTripleStumper: $isTripleStumper, allDone: $allDone, showInfoView: $showInfoView, category: $category)
                        } else if gamesVM.gameplayDisplay == .clue {
                            ClueView(unsolved: $unsolved, category: category, clue: clue, response: response, amount: amount, isDailyDouble: isDailyDouble, isTripleStumper: isTripleStumper)
                        }
                        if gamesVM.gamePhase == .finalTrivio && gamesVM.finalTrivioStage == .notBegun {
                            ContinueToFinalTrivioView()
                        }
                    }
                }
                InfoView(showInfoView: $showInfoView)
                    .shadow(radius: 20)
            }
        }
        .padding([.horizontal, .bottom], 30)
    }
}

struct GameplayHeaderView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showInfoView: Bool
    
    var headerString: String {
        switch gamesVM.gamePhase {
        case .trivio:
            return "Trivio! Round"
        case .doubleTrivio:
            return "Double Trivio! Round"
        default:
            return "Final Trivio! Round"
        }
    }
    
    var progressCount: Int {
        return gamesVM.usedAnswers.count
    }
    
    var cluesInRound: Int {
        return gamesVM.gamePhase == .trivio ? gamesVM.jRoundCompletes : gamesVM.djRoundCompletes
    }
    
    var body: some View {
        HStack {
            Button {
                gamesVM.gameSetupMode = .settings
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 30, weight: .bold))
            }
            
            Text("\(headerString)")
                .font(formatter.font(fontSize: .extraLarge))
            
            // Progress bar
            if gamesVM.gamePhase == .trivio || gamesVM.gamePhase == .doubleTrivio {
                GeometryReader { geometry in
                    VStack (alignment: .leading, spacing: 2) {
                        Spacer()
                        Text("Progress: \(progressCount) of \(cluesInRound) clues completed")
                        ZStack (alignment: .leading) {
                            Capsule()
                                .frame(width: geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.secondaryFG))
                            Capsule()
                                .frame(width: (CGFloat(progressCount) / CGFloat(cluesInRound)) * geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.primaryAccent))
                        }
                    }
                    .font(formatter.font(.regularItalic, fontSize: .small))
                }
                .frame(height: 45)
                .padding([.bottom, .horizontal], 10)
            } else if gamesVM.finalTrivioStage == .submitAnswer {
                FinalTrivioCountdownTimerView()
            } else {
                Spacer()
            }
            
            Button {
                showInfoView.toggle()
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 30, weight: .bold))
            }
        }
    }
}

struct ContinueToFinalTrivioView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @State var finalTrivioLoading = false
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.7)
            HStack {
                Button(action: {
                    gamesVM.finalTrivioStage = .makeWager
                }, label: {
                    HStack (spacing: 15) {
                        Text("Continue to Final Trivio!")
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .offset(x: finalTrivioLoading ? 20 : 0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    }
                    .font(formatter.font(fontSize: .large))
                    .foregroundColor(formatter.color(.primaryFG))
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .padding(.horizontal, 70)
                })
            }
            .background(formatter.color(.highContrastWhite))
            .clipShape(Capsule())
            .onAppear {
                finalTrivioLoading = true
            }
        }
    }
}

struct EmptyGameView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    var body: some View {
        VStack {
            Text("YOU HAVEN'T PICKED A GAME! TAP BELOW TO PICK ONE")
                .font(formatter.customFont(weight: "Bold Italic", iPadSize: 30))
                .foregroundColor(.white)
                .padding(20)
            Button(action: {
                gamesVM.menuChoice = .explore
            }, label: {
                Text("Pick a Game")
                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                    .foregroundColor(Color("Darkened"))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
}
