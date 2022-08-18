//
//  MobileClueView.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct MobileClueView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var unsolved: Bool
    
    let category: String
    let clue: String
    let response: String
    let amount: Int
    let isDailyDouble: Bool
    let isTripleStumper: Bool
    
    @State var wager: Double = 0
    @State var ddWagerMade = false
    
    var body: some View {
        ZStack {
            if isDailyDouble && !ddWagerMade {
                MobileDuplexWagerView(ddWagerMade: $ddWagerMade, wager: $wager, clue: clue)
            } else {
                MobileClueResponseView(unsolved: $unsolved, wager: $wager, isDailyDouble: isDailyDouble, isTripleStumper: isTripleStumper, clue: clue, category: category, response: response, amount: amount)
            }
        }
    }
}

struct MobileClueResponseView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var unsolved: Bool
    @Binding var wager: Double
    
    @State var timeElapsed: Double = 0
    @State var usedBlocks = [Int]()
    @State var showResponse = false
    @State var ddCorrect = true
    @State var teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
    @State var showingVolumeSlider = false
    
    let isDailyDouble: Bool
    let isTripleStumper: Bool
    let clue: String
    let category: String
    let response: String
    let amount: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            MobileClueCountdownTimerView(usedBlocks: $usedBlocks)
            VStack (spacing: 20) {
                // Category name and amount
                HStack {
                    HStack (spacing: 0) {
                        Text("\(category.uppercased()) for \(amount)")
                    }
                    .font(formatter.font())
                    Spacer()
                    Image(systemName: isDailyDouble ? "checkmark" : "xmark")
                        .font(formatter.iconFont(.small))
                }
                
                // Clue
                Text(clue)
                    .font(formatter.font(.regular, fontSize: .semiLarge))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                // Response, if showing response
                if self.showResponse {
                    VStack (spacing: 0) {
                        Text(response.capitalized)
                            .font(formatter.font(.regular, fontSize: .mediumLarge))
                            .foregroundColor(formatter.color(isTripleStumper ? .red : .secondaryAccent))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        if isTripleStumper {
                            Text("(Triple Stumper)")
                                .font(formatter.font(.regular, fontSize: .medium))
                                .foregroundColor(formatter.color(.red))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                Spacer()
                VStack {
                    if self.isDailyDouble {
                        if participantsVM.teams.count > 0 {
                            HStack {
                                Text("\(participantsVM.selectedTeam.name) (Wager: $\(Int(wager)))")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                Image(systemName: "xmark")
                                    .font(formatter.iconFont(.small))
                            }
                            .padding(15)
                            .frame(maxWidth: .infinity)
                            .background(self.ddCorrect ? formatter.color(.lowContrastWhite).opacity(0.4) : formatter.color(.red))
                            .clipShape(Capsule())
                            .onTapGesture {
                                formatter.hapticFeedback(style: .soft, intensity: .strong)
                                let teamIndex = participantsVM.selectedTeam.index
                                let wager = Int(self.ddCorrect ? -self.wager : self.wager)
                                self.participantsVM.editScore(index: teamIndex, amount: wager)
                                self.ddCorrect.toggle()
                            }
                        }
                    } else if showResponse {
                        MobileCorrectSelectorView(teamCorrect: $teamCorrect, amount: self.amount)
                    }
                    Text("  \(self.showResponse ? "Hide" : "Show") Response  ")
                        .font(formatter.font(fontSize: .regular))
                        .foregroundColor(formatter.color(showResponse ? .primaryBG : .highContrastWhite))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(showResponse ? formatter.color(.highContrastWhite) : nil)
                        .clipShape(Capsule())
                        .background(Capsule().stroke(formatter.color(.highContrastWhite), lineWidth: 3))
                        .contentShape(Capsule())
                        .onTapGesture {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            showResponse.toggle()
                        }
                }
            }
            .padding()
            .background(formatter.color(self.timeElapsed == self.gamesVM.timeRemaining ? .secondaryFG : .primaryAccent))
            .cornerRadius(15)
        }
        .onTapGesture {
            progressGame()
        }
        .onReceive(timer) { time in
            if !self.formatter.speaker.isSpeaking
                && self.timeElapsed < self.gamesVM.timeRemaining {
                self.timeElapsed += 1
                let elapsed = self.gamesVM.getCountdown(second: Int(timeElapsed))
                self.usedBlocks.append(contentsOf: [elapsed.upper, elapsed.lower])
            }
        }
    }
    
    func progressGame() {
        formatter.hapticFeedback(style: .rigid)
        gamesVM.gameplayDisplay = .grid
        gamesVM.usedAnswers.append(clue)
        formatter.speaker.stop()
        showResponse = false
        if self.ddCorrect && self.participantsVM.teams.count > 0 {
            let teamIndex = participantsVM.selectedTeam.index
            participantsVM.editScore(index: teamIndex, amount: Int(self.wager))
        }
        if !teamCorrect.id.isEmpty {
            participantsVM.addSolved()
        }
        
        if gamesVM.doneWithRound() && gamesVM.gamePhase == .doubleTrivio {
            gamesVM.gamePhase = .finalTrivio
        } else if gamesVM.doneWithRound() {
            gamesVM.moveOntoDoubleJeopardy()
            participantsVM.changeDJTeam()
        }
        participantsVM.incrementGameStep()
        participantsVM.resetSubtracts()
    }
}

struct MobileClueCountdownTimerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var usedBlocks: [Int]
    
    var body: some View {
        // Countdown timer blocks
        HStack (spacing: 2) {
            ForEach(0..<Int(self.gamesVM.timeRemaining * 2 - 1)) { i in
                Rectangle()
                    .foregroundColor(formatter.color(self.usedBlocks.contains(i + 1) ? .primaryFG : .secondaryAccent))
                    .frame(maxWidth: .infinity)
                    .frame(height: 7)
            }
        }
        .clipShape(Capsule())
    }
}

struct MobileCorrectSelectorView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var teamCorrect: Team
    
    var amount: Int
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack (spacing: 5) {
                ForEach(participantsVM.teams) { team in
                    HStack (spacing: 3) {
                        // xmark button
                        Button(action: {
                            formatter.hapticFeedback(style: .soft, intensity: .strong)
                            if team == teamCorrect {
                                teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
                                self.participantsVM.editScore(index: team.index, amount: -amount)
                            }
                            self.participantsVM.toSubtracts[team.index].toggle()
                            let amount = self.participantsVM.toSubtracts[team.index] ? -self.amount : self.amount
                            self.participantsVM.editScore(index: team.index, amount: amount)
                        }, label: {
                            Image(systemName: "xmark")
                                .font(formatter.iconFont(.small))
                                .padding(5)
                        })
                        RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 15)
                            .foregroundColor(formatter.color(.lowContrastWhite))
                            .padding(.trailing, 5)
                        Text("\(team.name)")
                            .font(formatter.font())
                            .onTapGesture {
                                markCorrect(teamIndex: team.index)
                            }
                        // check button
                        Button(action: {
                            markCorrect(teamIndex: team.index)
                        }, label: {
                            Image(systemName: "checkmark")
                                .font(formatter.iconFont(.small))
                                .padding(5)
                        })
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .padding(10)
                    
                    .background(formatter.color(.red).opacity(self.participantsVM.toSubtracts[team.index] ? 1 : 0))
                    .background(formatter.color(.green).opacity(team == teamCorrect ? 1 : 0))
                    .background(formatter.color(.lowContrastWhite).opacity(0.4))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    func markCorrect(teamIndex: Int) {
        formatter.hapticFeedback(style: .heavy)
        let team = participantsVM.teams[teamIndex]
        participantsVM.resetToLastIncrement(amount: amount)
        // if the contestant is marked wrong, unmark them wrong
        if participantsVM.toSubtracts[team.index] {
            participantsVM.toSubtracts[team.index].toggle()
            participantsVM.editScore(index: team.index, amount: amount)
        }
        if team == teamCorrect {
            // reset teamCorrect
            teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
            participantsVM.setSelectedTeam(index: participantsVM.defaultIndex)
        } else {
            participantsVM.editScore(index: team.index, amount: amount)
            teamCorrect = team
            participantsVM.setSelectedTeam(index: team.index)
        }
    }
}

struct MobileVolumeControlView: View {
    @EnvironmentObject var formatter: MasterHandler
    
    @Binding var showingVolumeSlider: Bool
    
    var speakerIconName: String {
        if formatter.volume > 0 && formatter.volume <= 0.33 {
            return "speaker.1.fill"
        } else if formatter.volume > 0.33 && formatter.volume <= 0.66 {
            return "speaker.2.fill"
        } else if formatter.volume > 0.66 {
            return "speaker.3.fill"
        } else {
            return "speaker.slash.fill"
        }
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: speakerIconName)
                    .font(formatter.iconFont(.small))
                if showingVolumeSlider {
                    Slider(value: Binding(get: {
                        formatter.volume
                    }, set: { (newVal) in
                        formatter.volume = newVal
                        formatter.setVolume()
                    }))
                    .accentColor(formatter.color(.secondaryAccent))
                    .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                Spacer()
            }
            .frame(width: 200)
            .frame(alignment: .leading)
            .onTapGesture {
                showingVolumeSlider.toggle()
            }
            if showingVolumeSlider {
                Text("Effective next clue")
                    .font(formatter.font(fontSize: .small))
            }
        }
    }
}

