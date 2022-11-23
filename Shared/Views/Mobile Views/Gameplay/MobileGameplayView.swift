//
//  MobileGameplayView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileGameplayView: View {
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
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            VStack (spacing: 10) {
                MobileGameplayHeaderView(showInfoView: $showInfoView)
                    .padding(.horizontal)
                MobilePlayersView()
                    .padding(.horizontal)
                MobileGameplayGridView(clue: $clue, value: $value, response: $response, amount: $amount, unsolved: $unsolved, isDailyDouble: $isDailyDouble, isTripleStumper: $isTripleStumper, allDone: $allDone, showInfoView: $showInfoView, category: $category)
            }
            .padding(.bottom)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .animation(.easeInOut)
    }
}

struct MobileGameplayGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var clue: String
    @Binding var value: String
    @Binding var response: String
    @Binding var amount: Int
    @Binding var unsolved: Bool
    @Binding var isDailyDouble: Bool
    @Binding var isTripleStumper: Bool
    @Binding var allDone: Bool
    @Binding var showInfoView: Bool
    @Binding var category: String
    
    var body: some View {
        ZStack {
            ZStack {
                if gamesVM.gamePhase == .finalRound && gamesVM.finalTrivioStage != .notBegun {
                    MobileFinalTrivioView()
                        .padding(.horizontal)
                } else {
                    if gamesVM.gameplayDisplay == .grid {
                        ScrollViewReader { scrollView in
                            ScrollView (.horizontal, showsIndicators: false) {
                                MobileGameGridView(clueString: $clue, pointValueString: $value, responseString: $response, amount: $amount, unsolved: $unsolved, isDailyDouble: $isDailyDouble, isTripleStumper: $isTripleStumper, allDone: $allDone, showInfoView: $showInfoView, category: $category)
                            }
                            .onAppear {
                                if gamesVM.currentCategoryIndex != 0 {
                                    scrollView.scrollTo(gamesVM.currentCategoryIndex, anchor: gamesVM.getUnitPoint())
                                }
                            }
                        }
                    } else if gamesVM.gameplayDisplay == .clue {
                        MobileClueView(unsolved: $unsolved, category: category, clueString: clue, responseString: response, pointValueInt: amount, isDailyDouble: isDailyDouble, isTripleStumper: isTripleStumper)
                            .padding(.horizontal)
                    }
                    if gamesVM.gamePhase == .finalRound && gamesVM.finalTrivioStage == .notBegun {
                        MobileContinueToFinalTrivioView()
                    }
                }
            }
            MobileInfoView(showInfoView: $showInfoView)
                .shadow(radius: 20)
        }
    }
}

struct MobileGameplayHeaderView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var showInfoView: Bool
    
    var headerString: String {
        switch gamesVM.gamePhase {
        case .round1:
            return "Trivio! Round"
        case .round2:
            return "Double Trivio! Round"
        default:
            return "Final Trivio! Round"
        }
    }
    
    var progressCount: Int {
        return gamesVM.usedAnswers.count
    }
    
    var cluesInRound: Int {
        return gamesVM.gamePhase == .round1 ? gamesVM.jRoundCompletes : gamesVM.djRoundCompletes
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    presentationMode.wrappedValue.dismiss()
                    gamesVM.gameSetupMode = .settings
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text("\(headerString)")
                    .font(formatter.font(fontSize: .semiLarge))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Spacer()
                
                Button {
                    formatter.hapticFeedback(style: .soft, intensity: .strong)
                    showInfoView.toggle()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                }
            }
            // Progress bar
            if gamesVM.gamePhase == .round1 || gamesVM.gamePhase == .round2 {
                GeometryReader { geometry in
                    VStack (alignment: .leading, spacing: 2) {
                        Spacer()
                        ZStack (alignment: .leading) {
                            Capsule()
                                .frame(width: geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.secondaryFG))
                            Capsule()
                                .frame(width: (CGFloat(progressCount) / CGFloat(cluesInRound)) * geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.primaryAccent))
                        }
                        HStack {
                            Text("Progress: \(progressCount) of \(cluesInRound) clues completed")
                            Spacer()
                            Button {
                                if gamesVM.gamePhase == .round1 {
                                    gamesVM.moveOntoRound2()
                                } else {
                                    gamesVM.gamePhase = gamesVM.gamePhase.next()
                                }
                            } label: {
                                Text("Skip round")
                                    .font(formatter.font(.boldItalic, fontSize: .small))
                            }

                        }
                    }
                    .font(formatter.font(.regularItalic, fontSize: .small))
                }
                .frame(height: 30)
            } else if gamesVM.finalTrivioStage == .submitAnswer {
                MobileFinalTrivioCountdownTimerView()
                    .padding(.top, 10)
            }
        }
    }
}

struct MobileContinueToFinalTrivioView: View {
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
                            .font(formatter.iconFont(.mediumLarge))
                            .offset(x: finalTrivioLoading ? 15 : 0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    }
                    .font(formatter.font(fontSize: .medium))
                    .foregroundColor(formatter.color(.primaryFG))
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.horizontal)
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

struct MobileEmptyGameView: View {
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

