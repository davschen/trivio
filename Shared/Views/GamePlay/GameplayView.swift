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
    @State var finalTrivioLoading = false
    
    var body: some View {
        VStack (spacing: 10) {
            PlayersView()
            ZStack {
                ZStack {
                    if gamesVM.selectedEpisode.isEmpty {
                        EmptyGameView()
                    } else {
                        GameGridView(clue: $clue, value: $value, response: $response, amount: $amount, finalJeopardySelected: $finalJeopardySelected, unsolved: $unsolved, isDailyDouble: $isDailyDouble, isTripleStumper: $isTripleStumper, allDone: $allDone, showInfoView: $showInfoView, category: $category)
                    }
                    if !self.clue.isEmpty {
                        AnswerView(clue: $clue, category: $category, value: $value, response: $response, amount: $amount, unsolved: $unsolved, isDailyDouble: self.isDailyDouble, isTripleStumper: self.isTripleStumper)
                            .onDisappear {
                                progressGame()
                            }
                    }
                    if allDone {
                        HStack {
                            Button(action: {
                                self.finalJeopardySelected.toggle()
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
                        .opacity(finalJeopardySelected ? 0 : 1)
                        .onAppear {
                            finalTrivioLoading = true
                        }
                    }
                    if finalJeopardySelected {
                        FinalJeopardyView(finalJeopardySelected: $finalJeopardySelected)
                            .onDisappear {
                                self.allDone.toggle()
                            }
                    }
                }
                InfoView(showInfoView: $showInfoView)
                    .shadow(radius: 20)
            }
        }
        .padding(30)
    }
    
    func progressGame() {
        if gamesVM.doneWithRound() && self.gamesVM.isDoubleJeopardy {
            self.allDone.toggle()
        } else if gamesVM.doneWithRound() {
            gamesVM.moveOntoDoubleJeopardy()
            participantsVM.changeDJTeam()
        }
        self.participantsVM.incrementGameStep()
        self.participantsVM.resetSubtracts()
    }
}

struct GameGridView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    @Binding var clue: String
    @Binding var value: String
    @Binding var response: String
    @Binding var amount: Int
    @Binding var finalJeopardySelected: Bool
    @Binding var unsolved: Bool
    @Binding var isDailyDouble: Bool
    @Binding var isTripleStumper: Bool
    @Binding var allDone: Bool
    @Binding var showInfoView: Bool
    @Binding var category: String
    
    @EnvironmentObject var formatter: MasterHandler
    
    var body: some View {
        VStack (spacing: 10) {
            HStack {
                Text("\(gamesVM.isDoubleJeopardy ? "Double Trivio! Round" : "Trivio! Round")")
                    .font(formatter.font(fontSize: .large))
                Image(systemName: "arrow.right.square.fill")
                    .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                    .onTapGesture {
                        if gamesVM.isDoubleJeopardy {
                            allDone = true
                        } else {
                            gamesVM.moveOntoDoubleJeopardy()
                            participantsVM.changeDJTeam()
                        }
                    }
                Spacer()
                Image(systemName: "info.circle.fill")
                    .font(formatter.deviceType == .iPad ? .largeTitle : .title3)
                    .onTapGesture {
                        showInfoView.toggle()
                    }
            }
            HStack (spacing: 10) {
                ForEach(0..<(gamesVM.categories.count), id: \.self) { i in
                    let category: String = gamesVM.categories[i]
                    ZStack {
                        formatter.color(self.gamesVM.categoryDone(colIndex: i) ? .primaryFG : .primaryAccent)
                        Text("\(self.gamesVM.categoryDone(colIndex: i) ? "" : category.uppercased())")
                            .font(formatter.font(.extraBold, fontSize: .medium))
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.1)
                    }
                    .cornerRadius(10)
                }
            }
            .frame(height: formatter.deviceType == .iPad ? 150 : 75)
            .padding(.bottom, formatter.deviceType == .iPad ? 10 : 5)

            // grid where the clue magic happens
            HStack (spacing: 10) {
                ForEach(0..<gamesVM.categories.count, id: \.self) { i in
                    VStack (spacing: 10) {
                        ForEach(0..<self.gamesVM.moneySections.count, id: \.self) { j in
                            let clueCounts: Int = gamesVM.clues[i].count
                            let responsesCounts: Int = gamesVM.responses[i].count
                            let gridClue: String = clueCounts - 1 >= j ? gamesVM.clues[i][j] : ""
                            let gridResponse: String = responsesCounts - 1 >= j ? gamesVM.responses[i][j] : ""
                            GameCellView(gridClue: gridClue, j: j)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(formatter.cornerRadius(iPadSize: 5))
                                .shadow(color: Color.black.opacity(0.2), radius: 10)
                            .onTapGesture {
                                if !(self.gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty) {
                                    self.gamesVM.addToCompletes(colIndex: i)
                                    self.unsolved = false
                                    self.updateDailyDouble(i: i, j: j)
                                    self.updateTripleStumper(i: i, j: j)
                                    self.clue = gridClue
                                    self.response = gridResponse
                                    self.gamesVM.usedAnswers.append(gridClue)
                                    self.amount = Int(self.gamesVM.moneySections[j]) ?? 0
                                    self.category = self.gamesVM.categories[i]
                                    self.value = self.gamesVM.moneySections[j]
                                    participantsVM.setDefaultIndex()
                                }
                            }
                            .onLongPressGesture {
                                if self.gamesVM.usedAnswers.contains(gridClue) && !gridClue.isEmpty {
                                    self.gamesVM.removeAnswer(answer: gridClue)
                                    self.gamesVM.removeFromCompletes(colIndex: i)
                                }
                            }
                        }
                    }
                }
            }
        }
        .opacity(self.clue.isEmpty ? 1 : 0)
        .opacity(allDone ? 0.4 : 1)
        .opacity(self.finalJeopardySelected ? 0 : 1)
    }
    
    func updateDailyDouble(i: Int, j: Int) {
        let toCheck: [Int] = [j, i]
        if !self.gamesVM.isDoubleJeopardy {
            self.isDailyDouble = toCheck == self.gamesVM.jeopardyDailyDoubles
        } else {
            self.isDailyDouble = (toCheck == self.gamesVM.djDailyDoubles1 || toCheck == self.gamesVM.djDailyDoubles2)
        }
    }
    
    func updateTripleStumper(i: Int, j: Int) {
        let toCheck: [Int] = [i, j]
        if !self.gamesVM.isDoubleJeopardy {
            self.isTripleStumper = self.gamesVM.jTripleStumpers.contains(toCheck)
        } else {
            self.isTripleStumper = self.gamesVM.djTripleStumpers.contains(toCheck)
        }
    }
}

struct GameCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    var gridClue: String
    var j: Int
    
    var body: some View {
        ZStack {
            formatter.color(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty ? .primaryFG : .primaryAccent)
            Text("$\(gamesVM.moneySections[j])")
                .font(formatter.font(.extraBold, fontSize: .large))
                .foregroundColor(formatter.color(.secondaryAccent))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                .multilineTextAlignment(.center)
                .opacity(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty ? 0 : 1)
                .minimumScaleFactor(0.1)
        }
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10)
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

struct InfoView: View {
    @EnvironmentObject var gamesVM: GamesViewModel
    @Binding var showInfoView: Bool
    
    @EnvironmentObject var formatter: MasterHandler
    var customSet: CustomSet {
        return gamesVM.customSet
    }
    
    var body: some View {
        ZStack {
            Color("MainBG")
                .edgesIgnoringSafeArea(.all)
                .opacity(showInfoView ? 0.6 : 0)
                .onTapGesture {
                    self.showInfoView.toggle()
                }
            HStack {
                VStack (alignment: .leading) {
                    HStack {
                        Text("Title: " + "\(gamesVM.title)")
                            .font(formatter.customFont(weight: "Bold", iPadSize: 30))
                            .padding(formatter.padding())
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(5)
                    }
                    Text("Date Created: " + "\(gamesVM.dateFormatter.string(from: customSet.dateCreated))")
                    if gamesVM.rating > 0 {
                        Text("Rating: " + "\(round(customSet.rating))/5")
                    }
                    if gamesVM.customSet.plays > 0 {
                        Text("Plays: " + "\(customSet.plays)")
                        Text("Average Rating: " + "\(customSet.rating)/5")
                        Text("Average Score: " + "\(customSet.averageScore.formatPoints())")
                        Text("Number of Clues: " + "\(customSet.numclues)")
                    }
                    Spacer()
                }
                .font(formatter.customFont(weight: "Bold", iPadSize: 20))
                .padding()
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
            .background(Color("MainFG"))
            .cornerRadius(20)
            .offset(y: self.showInfoView ? 0 : UIScreen.main.bounds.height)
        }
    }
}
