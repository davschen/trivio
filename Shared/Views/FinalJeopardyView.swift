//
//  FinalJeopardyView.swift
//  Trivio
//
//  Created by David Chen on 2/9/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct FinalJeopardyView: View {
    @EnvironmentObject var buildVM: BuildViewModel
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @Binding var finalJeopardySelected: Bool
    
    @State var finalJeopardyReveal = false
    @State var timeRemaining: Double = 30
    @State var musicPlaying = false
    @State var rating = 0
    
    @EnvironmentObject var formatter: MasterHandler
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Wagers View
            if !gamesVM.wagersMade {
                VStack {
                    VStack {
                        ScrollView (.vertical, showsIndicators: false) {
                            CategoryLargeView(categoryName: gamesVM.fjCategory)
                            HStack {
                                Text("Your wager cannot be larger than your score")
                                Spacer()
                            }
                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                            ForEach(0..<self.participantsVM.teams.count) { i in
                                let team = self.participantsVM.teams[i]
                                if team.score >= 0 {
                                    HStack {
                                        HStack {
                                            Circle()
                                                .foregroundColor(ColorMap().getColor(color: team.color))
                                                .frame(width: 10)
                                            Text(team.name)
                                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                                .foregroundColor(.white)
                                            if participantsVM.teamHasLock(teamIndex: i) {
                                                Image(systemName: "lock.fill")
                                            }
                                        }
                                        .padding()
                                        .frame(width: 150, height: 50)
                                        .background(Color.gray.opacity(0.4))
                                        .cornerRadius(5)
                                        .padding(.horizontal)
                                        HStack (spacing: 0) {
                                            Text("Wager: ")
                                            PrivateTextFieldView(text: $participantsVM.wagers[i], reveal: $finalJeopardyReveal, teamIndex: i, type: "wager")
                                        }
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                        .cornerRadius(5)
                                        .padding()
                                    }
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(5)
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    if participantsVM.wagersValid() {
                                        gamesVM.wagersMade.toggle()
                                        formatter.speaker.speak(gamesVM.fjClue)
                                    }
                                }, label: {
                                    Text("Finished")
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                        .foregroundColor(Color.white)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(5.0)
                                })
                                .opacity(participantsVM.wagersValid() ? 1 : 0.2)
                            }
                        }
                        .resignKeyboardOnDragGesture()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("MainFG"))
                .cornerRadius(10)
                .keyboardAware()
            } else {
                // Answer View
                ScrollView (.vertical) {
                    VStack {
                        HStack {
                            Text("Final Jeopardy Round")
                                .foregroundColor(Color.white)
                                .font(formatter.customFont(weight: "Bold", iPadSize: 50))
                                .padding()
                            Text("Reveal")
                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                .foregroundColor(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                .padding(10)
                                .background(Color.gray.opacity(self.finalJeopardyReveal ? 1 : 0.4))
                                .cornerRadius(5.0)
                                .padding(5)
                                .onTapGesture {
                                    self.finalJeopardyReveal.toggle()
                                }
                            Spacer()
                        }
                        CategoryLargeView(categoryName: gamesVM.fjCategory)
                        GeometryReader { geometry in
                            Rectangle()
                                .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 30) : 0)
                                .foregroundColor(Color("MainAccent"))
                                .animation(.easeInOut)
                        }
                        .frame(height: timeRemaining > 0 ? formatter.shrink(iPadSize: 50) : 0)
                        .padding(.horizontal, formatter.padding())
                        .onReceive(timer) { time in
                            if self.timeRemaining > 0 && !self.formatter.speaker.isSpeaking && gamesVM.wagersMade {
                                self.timeRemaining -= 1
                                if !self.musicPlaying {
                                    self.musicPlaying.toggle()
                                    self.formatter.speaker.playSounds("FinalJeopardy.mp3")
                                }
                            }
                        }
                        VStack {
                            Text(self.gamesVM.fjClue)
                                .frame(alignment: .leading)
                                .foregroundColor(.white)
                                .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                .padding()
                            if self.finalJeopardyReveal {
                                VStack {
                                    HStack {
                                        Text("CORRECT RESPONSE")
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            .padding(10)
                                            .background(Color.white.opacity(0.4))
                                            .cornerRadius(5)
                                        Spacer()
                                    }
                                    Text(gamesVM.fjResponse)
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                        .padding(.vertical, formatter.padding(size: 40))
                                    HStack {
                                        Spacer()
                                        RatingView(rating: $rating)
                                        Button(action: {
                                            self.finalJeopardySelected.toggle()
                                            self.participantsVM.incrementGameStep()
                                            self.profileVM.markAsPlayed(gameID: gamesVM.selectedEpisode)
                                            self.participantsVM.writeToFirestore(gameID: gamesVM.selectedEpisode, myRating: rating)
                                            self.participantsVM.resetScores()
                                            self.gamesVM.reset()
                                        }, label: {
                                            Text("Finish Game")
                                                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                                .foregroundColor(Color("MainAccent"))
                                                .shadow(color: Color.black.opacity(0.2), radius: 5)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                                .background(Color.gray.opacity(0.5))
                                                .cornerRadius(5)
                                        })
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("LoMainFG"))
                                .cornerRadius(5)
                                .padding()
                            }
                        }
                        ForEach(0..<self.participantsVM.teams.count) { i in
                            let team = self.participantsVM.teams[i]
                            if team.score >= 0 {
                                HStack {
                                    HStack {
                                        VStack {
                                            HStack {
                                                Circle()
                                                    .foregroundColor(ColorMap().getColor(color: team.color))
                                                    .frame(width: 10)
                                                Text(team.name)
                                                if participantsVM.teamHasLock(teamIndex: team.index) {
                                                    Image(systemName: "lock.fill")
                                                }
                                            }
                                            .padding()
                                            .frame(width: 150, height: 50)
                                            .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            .background(Color.gray.opacity(0.4))
                                            .cornerRadius(5)
                                            .padding(.horizontal)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                            if finalJeopardyReveal {
                                                Text("Wager: " + participantsVM.wagers[i])
                                                    .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                                            }
                                        }
                                        HStack (spacing: 0) {
                                            Text("Answer: ")
                                            PrivateTextFieldView(text: $participantsVM.finalJeopardyAnswers[i], reveal: $finalJeopardyReveal, teamIndex: i, type: "answer")
                                        }
                                        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                                        .cornerRadius(5)
                                        .padding()
                                    }
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(5)
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .font(formatter.deviceType == .iPad ? .title : .subheadline)
                                            .padding(10)
                                            .foregroundColor(Color("MainFG"))
                                            .background(Color.white.opacity(self.participantsVM.fjCorrects[team.index] ? 1 : 0.4))
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                if self.participantsVM.toSubtracts[team.index] {
                                                    self.participantsVM.addFJIncorrect(index: team.index)
                                                }
                                                self.participantsVM.addFJCorrect(index: team.index)
                                            }
                                        Image(systemName: "xmark")
                                            .font(formatter.deviceType == .iPad ? .title : .subheadline)
                                            .padding(10)
                                            .foregroundColor(Color("MainFG"))
                                            .background(Color.white.opacity(self.participantsVM.toSubtracts[team.index] ? 1 : 0.4))
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                if self.participantsVM.fjCorrects[team.index] {
                                                    self.participantsVM.addFJCorrect(index: team.index)
                                                }
                                                self.participantsVM.addFJIncorrect(index: team.index)
                                            }
                                    }
                                }
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("MainFG"))
                .cornerRadius(10)
                .opacity(gamesVM.wagersMade ? 1 : 0)
                .keyboardAware()
                .onAppear {
                    if self.timeRemaining < 30 {
                        self.formatter.speaker.playSounds("FinalJeopardy.mp3")
                    }
                }
            }
        }
    }
}

struct PrivateTextFieldView: View {
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var text: String
    @Binding var reveal: Bool
    @State var visible = false
    var teamIndex: Int
    var type: String
    @EnvironmentObject var formatter: MasterHandler
    
    var validEntry: Bool {
        if type == "wager" {
            let wager = participantsVM.wagers[teamIndex]
            return !wager.isEmpty && !(Int(wager) == nil) && (Int(wager)! >= 0)
        } else {
            let answer = participantsVM.finalJeopardyAnswers[teamIndex]
            return !answer.isEmpty
        }
    }
    
    var hideText: String {
        if type == "wager" {
            return validEntry ? "Wager Made!" : "Make your wager"
        } else {
            return validEntry ? "Answer Submitted!" : "Submit your answer"
        }
    }
    
    var body: some View {
        ZStack {
            HStack (spacing: 0) {
                Text(type == "wager" ? "$" : "")
                ZStack {
                    if reveal {
                        HStack {
                            Text(text)
                            Spacer()
                        }
                    } else {
                        SecureField("Enter \(type == "wager" ? "Wager" : "Answer")", text: $text) {
                            visible = false
                        }
                        .keyboardType(type == "wager" ? .numberPad : .default)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Button(action: {
                    visible = false
                }, label: {
                    Image(systemName: "eye.slash.fill")
                })
            }
            HStack {
                Text(hideText)
                    .font(formatter.customFont(weight: "Bold Italic", iPadSize: 30))
                    .frame(alignment: .leading)
                    .opacity(validEntry ? 1 : 0.4)
                Spacer()
                Button(action: {
                    visible = true
                }, label: {
                    Image(systemName: "eye.fill")
                })
            }
            .padding(.vertical, formatter.padding())
            .padding(5)
            .background(Color("LoMainFG"))
            .opacity(visible ? 0 : 1)
            .cornerRadius(5)
            .onTapGesture {
                visible = true
            }
        }
        .font(formatter.customFont(weight: "Bold", iPadSize: 30))
        .padding(5)
        .background(Color("MainFG"))
        .cornerRadius(5)
        .foregroundColor(.white)
        .accentColor(.white)
    }
}

struct RatingView: View {
    @Binding var rating: Int
    @EnvironmentObject var formatter: MasterHandler
    var range: [Int] {
        var retRange = [Int]()
        for i in (0..<5) {
            retRange.append(i)
        }
        return retRange
    }
    var body: some View {
        HStack {
            Text("Rate this set!")
                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
            HStack (spacing: 3) {
                ForEach(range, id: \.self) { i in
                    Image(systemName: "largecircle.fill.circle")
                        .font(.title2)
                        .foregroundColor(rating >= i + 1 ? Color("MainAccent") : Color("MainFG"))
                        .onTapGesture {
                            rating = i + 1
                        }
                }
            }
        }
    }
}
