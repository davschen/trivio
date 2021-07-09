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
                if (gamesVM.timeRemaining > 0) {
                    HStack (spacing: formatter.deviceType == .iPad ? nil : 5) {
                        ForEach(0..<Int(self.gamesVM.timeRemaining * 2 - 1)) { i in
                            Rectangle()
                                .foregroundColor(self.usedBlocks.contains(i + 1) ? Color("MainBG") : .red)
                                .frame(maxWidth: .infinity)
                                .frame(height: formatter.deviceType == .iPad ? 50 : 20)
                        }
                    }
                    .padding([.top, .horizontal], 5)
                }
                
                ZStack {
                    Color(self.timeElapsed == self.gamesVM.timeRemaining ? "Darkened" : "MainFG")
                    VStack {
                        Text(clue.uppercased())
                            .font(formatter.customFont(weight: "Bold", iPadSize: 35))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.1)
                            .padding()
                        if self.showResponse {
                            VStack (spacing: 0) {
                                Text(response.uppercased())
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 35))
                                    .foregroundColor(self.isTripleStumper ? Color.red : Color("MainAccent"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .multilineTextAlignment(.center)
                                if isTripleStumper {
                                    Text("(Triple Stumper)")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                        .foregroundColor(Color.red)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    // volume control and category
                    VStack {
                        ZStack {
                            HStack {
                                VolumeControlView()
                                Spacer()
                            }
                            Text("\(category.uppercased()) - $\(self.value)")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                .foregroundColor(.white)
                                .padding(formatter.padding())
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(5)
                                .padding()
                        }
                        Spacer()
                    }
                    
                    VStack {
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
                                            .font(.title3.weight(.black))
                                    }
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
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
                            Text("\(self.showResponse ? "Hide" : "Show") Response")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                .foregroundColor(Color("MainAccent"))
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding(formatter.padding())
                                .background(Color.gray.opacity(self.showResponse ? 1 : 0.4))
                                .cornerRadius(formatter.cornerRadius(5))
                                .padding(5)
                                .onTapGesture {
                                    self.showResponse.toggle()
                                }
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
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
                        .font(formatter.customFont(weight: "Bold", iPadSize: 80))
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                        .multilineTextAlignment(.center)
                        .padding()
                    VStack {
                        Slider(value: $wager, in: 0...Double(max(maxScore, participantsVM.teams.indices.contains(participantsVM.selectedTeam.index) ? participantsVM.teams[participantsVM.selectedTeam.index].score : 0)), step: 100)
                            .accentColor(Color("MainAccent"))
                        HStack {
                            Text("Wager: \(Int(self.wager))")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .multilineTextAlignment(.center)
                            Spacer(minLength: 30)
                            Button(action: {
                                self.usedBlocks.removeAll()
                                self.ddWagerMade.toggle()
                                self.timeElapsed = 0
                                self.formatter.speaker.speak(self.clue)
                            }) {
                                Text("Done")
                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                    .foregroundColor(Color("MainAccent"))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                                    .padding()
                                    .background(Color.gray.opacity(0.4))
                                    .cornerRadius(5.0)
                                    .padding(5)
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width / 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("MainFG"))
                .cornerRadius(formatter.cornerRadius(iPadSize: 20))
                .opacity(self.ddWagerMade ? 0 : 1)
//                .onAppear {
//                    self.speaker.playSounds("dailyDouble.m4a")
//                }
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
            HStack (spacing: formatter.deviceType == .iPad ? nil : 3) {
                ForEach(participantsVM.teams) { team in
                    HStack {
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
                                .font(formatter.deviceType == .iPad ? .title3.weight(.black) : .caption.weight(.black))
                                .padding(5)
                        })
                        
                        Text("\(team.name)")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            .foregroundColor(Color("MainAccent"))
                            .onTapGesture {
                                markCorrect(teamIndex: team.index)
                            }
                        
                        // check button
                        Button(action: {
                            markCorrect(teamIndex: team.index)
                        }, label: {
                            Image(systemName: "checkmark")
                                .font(formatter.deviceType == .iPad ? .title3.weight(.black) : .caption.weight(.black))
                                .padding(5)
                        })
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .padding(formatter.padding())
                    .background(Color.red.opacity(self.participantsVM.toSubtracts[team.index] ? 0.5 : 0))
                    .background(Color.green.opacity(team == teamCorrect ? 0.5 : 0))
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(formatter.cornerRadius(5))
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
                    .accentColor(Color("MainAccent"))
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
                    .font(formatter.customFont(iPadSize: 15))
            }
        }
        .padding(.horizontal, formatter.shrink(iPadSize: 40))
    }
}
