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
    
    @State var showInfoView = false
    
    var body: some View {
        ZStack {
            formatter.color(.primaryBG)
                .edgesIgnoringSafeArea(.all)
            VStack (spacing: 10) {
                MobileGameplayHeaderView(showInfoView: $showInfoView)
                    .padding(.horizontal)
                MobilePlayersView()
                    .padding(.horizontal)
                MobileGameplayGridView(showInfoView: $showInfoView)
            }
            .padding(.bottom)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .animation(.easeInOut(duration: 0.3))
    }
}

struct MobileGameplayGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var showInfoView: Bool
    
    var body: some View {
        ZStack {
            ZStack {
                if gamesVM.gamePhase == .finalRound && gamesVM.finalTrivioStage != .notBegun {
                    MobileFinalTrivioView()
                        .padding(.horizontal)
                } else {
                    if gamesVM.gameplayDisplay == .grid {
                        MobileGameGridView()
                    } else if gamesVM.gameplayDisplay == .clue {
                        MobileClueView()
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
            return "Final Trivio!"
        }
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
                        .font(.system(size: 20))
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
                    Image(systemName: "info.circle")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            // Progress bar
            if gamesVM.gamePhase == .round1 || gamesVM.gamePhase == .round2 {
                GeometryReader { geometry in
                    VStack (alignment: .leading, spacing: 4) {
                        Spacer()
                        ZStack (alignment: .leading) {
                            Capsule()
                                .frame(width: geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.secondaryFG))
                            Capsule()
                                .frame(width: (CGFloat(gamesVM.getNumCompletedClues()) / CGFloat(cluesInRound)) * geometry.size.width, height: 10)
                                .foregroundColor(formatter.color(.primaryAccent))
                        }
                        HStack {
                            Text("Progress: \(gamesVM.getNumCompletedClues()) of \(cluesInRound) clues completed")
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
