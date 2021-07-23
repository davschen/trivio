//
//  AnswerView.swift
//  Trivio
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct ClueView: View {
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
                DailyDoubleWagerView(ddWagerMade: $ddWagerMade, wager: $wager, clue: clue)
            } else {
                ClueResponseView(unsolved: $unsolved, wager: $wager, isDailyDouble: isDailyDouble, isTripleStumper: isTripleStumper, clue: clue, category: category, response: response, amount: amount)
            }
        }
    }
}

struct ClueResponseView: View {
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
    
    let isDailyDouble: Bool
    let isTripleStumper: Bool
    let clue: String
    let category: String
    let response: String
    let amount: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ClueCountdownTimerView(usedBlocks: $usedBlocks)
            VStack {
                // Volume control and category name
                ZStack {
                    HStack {
                        VolumeControlView()
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                    }
                    Text("\(category.uppercased()) - $\(amount)")
                        .font(formatter.font(fontSize: .mediumLarge))
                        .padding(formatter.padding())
                        .background(formatter.color(.lowContrastWhite))
                        .cornerRadius(5)
                }
                .padding()
                Spacer()
                Text(clue.uppercased())
                    .font(formatter.font(fontSize: .large))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding()
                if self.showResponse {
                    VStack (spacing: 0) {
                        Text(response.uppercased())
                            .font(formatter.font(fontSize: .large))
                            .foregroundColor(formatter.color(self.isTripleStumper ? .red : .secondaryAccent))
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .multilineTextAlignment(.center)
                        if isTripleStumper {
                            Text("(Triple Stumper)")
                                .font(formatter.font(fontSize: .medium))
                                .foregroundColor(formatter.color(.red))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    if self.isDailyDouble {
                        if participantsVM.teams.count > 0 {
                            HStack {
                                Text("\(participantsVM.selectedTeam.name) (Wager: $\(Int(wager)))")
                                    .font(formatter.font(fontSize: .mediumLarge))
                                Image(systemName: "xmark")
                                    .font(.system(size: 25, weight: .bold))
                            }
                            .padding(25)
                            .background(self.ddCorrect ? formatter.color(.lowContrastWhite).opacity(0.4) : formatter.color(.red))
                            .clipShape(Capsule())
                            .onTapGesture {
                                let teamIndex = participantsVM.selectedTeam.index
                                let wager = Int(self.ddCorrect ? -self.wager : self.wager)
                                self.participantsVM.editScore(index: teamIndex, amount: wager)
                                self.ddCorrect.toggle()
                            }
                        }
                    } else {
                        CorrectSelectorView(teamCorrect: $teamCorrect, amount: self.amount)
                    }
                    Text("  \(self.showResponse ? "Hide" : "Show") Response  ")
                        .font(formatter.font(fontSize: .mediumLarge))
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .padding(25)
                        .background(formatter.color(.lowContrastWhite).opacity(showResponse ? 1 : 0.4))
                        .clipShape(Capsule())
                        .onTapGesture {
                            self.showResponse.toggle()
                        }
                }
            }
            .padding(20)
            .background(formatter.color(self.timeElapsed == self.gamesVM.timeRemaining ? .secondaryFG : .primaryAccent))
            .cornerRadius(40)
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
        self.participantsVM.incrementGameStep()
        self.participantsVM.resetSubtracts()
    }
}

struct ClueCountdownTimerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var usedBlocks: [Int]
    
    var body: some View {
        // Countdown timer blocks
        HStack (spacing: formatter.deviceType == .iPad ? nil : 5) {
            ForEach(0..<Int(self.gamesVM.timeRemaining * 2 - 1)) { i in
                Rectangle()
                    .foregroundColor(formatter.color(self.usedBlocks.contains(i + 1) ? .primaryFG : .secondaryAccent))
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
            }
        }
        .clipShape(Capsule())
        .padding(.vertical, 5)
    }
}

struct CorrectSelectorView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var teamCorrect: Team
    
    var amount: Int
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            HStack (spacing: 15) {
                ForEach(participantsVM.teams) { team in
                    HStack (spacing: 10) {
                        // xmark button
                        Button(action: {
                            if team == teamCorrect {
                                teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
                                self.participantsVM.editScore(index: team.index, amount: -amount)
                            }
                            self.participantsVM.toSubtracts[team.index].toggle()
                            let amount = self.participantsVM.toSubtracts[team.index] ? -self.amount : self.amount
                            self.participantsVM.editScore(index: team.index, amount: amount)
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 25, weight: .bold))
                                .padding(5)
                        })
                        RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 25)
                            .padding(.horizontal, 5)
                        Text("\(team.name)")
                            .font(formatter.font(fontSize: .mediumLarge))
                            .padding(.horizontal, 5)
                            .onTapGesture {
                                markCorrect(teamIndex: team.index)
                            }
                        // check button
                        Button(action: {
                            markCorrect(teamIndex: team.index)
                        }, label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 25, weight: .bold))
                                .padding(5)
                        })
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .padding(20)
                    .background(formatter.color(.red).opacity(self.participantsVM.toSubtracts[team.index] ? 1 : 0))
                    .background(formatter.color(.green).opacity(team == teamCorrect ? 1 : 0))
                    .background(formatter.color(.lowContrastWhite).opacity(0.4))
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    func markCorrect(teamIndex: Int) {
        let team = participantsVM.teams[teamIndex]
        participantsVM.resetToLastIncrement(amount: amount)
        // if the contestant is marked wrong, unmark them wrong
        if participantsVM.toSubtracts[team.index] {
            participantsVM.toSubtracts[team.index].toggle()
            participantsVM.editScore(index: team.index, amount: amount)
        }
        if team == teamCorrect {
            // reset teamCorrect
            self.teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
            participantsVM.setSelectedTeam(index: participantsVM.defaultIndex)
        } else {
            participantsVM.editScore(index: team.index, amount: amount)
            self.teamCorrect = team
            participantsVM.setSelectedTeam(index: team.index)
        }
    }
}

struct VolumeControlView: View {
    @EnvironmentObject var formatter: MasterHandler
    @State var showingVolumeSlider = false
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
                    .font(.system(size: 20, weight: .bold))
                if showingVolumeSlider {
                    Slider(value: Binding(get: {
                        self.formatter.volume
                    }, set: { (newVal) in
                        self.formatter.volume = newVal
                        self.formatter.setVolume()
                    }))
                    .accentColor(formatter.color(.secondaryAccent))
                    .foregroundColor(formatter.color(.mediumContrastWhite))
                }
                Spacer()
            }
            .frame(width: formatter.shrink(iPadSize: 200, factor: 1.5))
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
