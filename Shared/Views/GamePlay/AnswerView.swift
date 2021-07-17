//
//  AnswerView.swift
//  Trivio
//
//  Created by David Chen on 2/4/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct AnswerView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    
    @Binding var clue: String
    @Binding var category: String
    @Binding var value: String
    @Binding var response: String
    @Binding var amount: Int
    @Binding var unsolved: Bool
    @State var isDailyDouble: Bool
    @State var isTripleStumper: Bool
    
    @State var timeElapsed: Double = 0
    @State var showResponse = false
    @State var wager: Double = 0
    @State var ddWagerMade = false
    @State var ddCorrect = true
    @State var usedBlocks = [Int]()
    @State var teamCorrect = Team(index: 0, name: "", members: [], score: 0, color: "")
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var maxScore: Int {
        return gamesVM.isDoubleJeopardy ? 2000 : 1000
    }
    
    var body: some View {
        ZStack {
            VStack {
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
                .padding(.vertical)
                .padding(.horizontal, 5)
                VStack {
                    ZStack {
                        HStack {
                            VolumeControlView()
                            Spacer()
                        }
                        Text("\(category.uppercased()) - $\(self.value)")
                            .font(formatter.font(fontSize: .mediumLarge))
                            .foregroundColor(.white)
                            .padding(formatter.padding())
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                            .padding()
                    }
                    Spacer()
                    Text(clue.uppercased())
                        .font(formatter.font(fontSize: .large))
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .multilineTextAlignment(.center)
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
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                        .foregroundColor(Color("MainAccent"))
                                    Image(systemName: "xmark")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .padding(formatter.padding())
                                .background(Color.red.opacity(self.ddCorrect ? 0 : 0.5))
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(formatter.cornerRadius(5))
                                .padding(5)
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
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .padding(25)
                            .background(formatter.color(.lowContrastWhite).opacity(showResponse ? 1 : 0.4))
                            .clipShape(Capsule())
                            .onTapGesture {
                                self.showResponse.toggle()
                            }
                    }
                    .padding()
                }
                .padding(20)
                .background(formatter.color(self.timeElapsed == self.gamesVM.timeRemaining ? .secondaryFG : .primaryAccent))
                .cornerRadius(40)
            }
            .onTapGesture {
                clue = ""
                formatter.speaker.stop()
                showResponse = false
                if self.ddCorrect && self.participantsVM.teams.count > 0 {
                    let teamIndex = participantsVM.selectedTeam.index
                    participantsVM.editScore(index: teamIndex, amount: Int(self.wager))
                }
                if !teamCorrect.id.isEmpty {
                    participantsVM.addSolved()
                }
            }
            .onAppear {
                if !self.isDailyDouble {
                    self.formatter.speaker.speak(self.clue)
                }
            }
            .onReceive(timer) { time in
                if !self.formatter.speaker.isSpeaking
                    && self.timeElapsed < self.gamesVM.timeRemaining
                    && ((isDailyDouble && ddWagerMade) || !isDailyDouble) {
                    self.timeElapsed += 1
                    let elapsed = self.gamesVM.getCountdown(second: Int(timeElapsed))
                    self.usedBlocks.append(contentsOf: [elapsed.upper, elapsed.lower])
                }
            }
            if self.isDailyDouble {
                VStack {
                    Text("DUPLEX OF THE DAY")
                        .font(formatter.font(fontSize: .extraLarge))
                        .foregroundColor(formatter.color(.highContrastWhite))
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .multilineTextAlignment(.center)
                        .padding()
                    VStack {
                        Slider(value: $wager, in: 0...Double(max(maxScore, participantsVM.teams.indices.contains(participantsVM.selectedTeam.index) ? participantsVM.teams[participantsVM.selectedTeam.index].score : 0)), step: 100)
                            .accentColor(formatter.color(.secondaryAccent))
                        HStack {
                            Text("Wager: \(Int(self.wager))")
                                .font(formatter.font())
                                .foregroundColor(formatter.color(.highContrastWhite))
                                .multilineTextAlignment(.center)
                            Spacer(minLength: 30)
                            Button(action: {
                                self.usedBlocks.removeAll()
                                self.ddWagerMade.toggle()
                                self.timeElapsed = 0
                                self.formatter.speaker.speak(self.clue)
                            }) {
                                Text("Done")
                                    .font(formatter.font())
                                    .foregroundColor(formatter.color(.highContrastWhite))
                                    .padding()
                                    .background(formatter.color(.lowContrastWhite))
                                    .cornerRadius(5.0)
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width / 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(formatter.color(.primaryAccent))
                .cornerRadius(40)
                .opacity(self.ddWagerMade ? 0 : 1)
            }
        }
    }
}

struct CorrectSelectorView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var teamCorrect: Team
    
    var amount: Int
    @EnvironmentObject var formatter: MasterHandler
    
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
                                .foregroundColor(formatter.color(.highContrastWhite))
                                .padding(5)
                        })
                        RoundedRectangle(cornerRadius: 2).frame(width: 1, height: 25)
                            .padding(.horizontal, 5)
                        Text("\(team.name)")
                            .font(formatter.font(fontSize: .mediumLarge))
                            .foregroundColor(formatter.color(.highContrastWhite))
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
                    .font(.system(size: formatter.shrink(iPadSize: 20, factor: 1.5)))
                if showingVolumeSlider {
                    Slider(value: Binding(get: {
                        self.formatter.volume
                    }, set: { (newVal) in
                        self.formatter.volume = newVal
                        self.formatter.setVolume()
                    }))
                    .accentColor(formatter.color(.secondaryAccent))
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
        .padding(.horizontal, formatter.shrink(iPadSize: 40))
    }
}
