//
//  GameGridView.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 7/19/21.
//

import Foundation
import SwiftUI

struct GameGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
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
        VStack (spacing: 5) {
            HStack (spacing: 7) {
                
                // Category name
                ForEach(0..<(gamesVM.categories.count), id: \.self) { i in
                    let category: String = gamesVM.categories[i]
                    ZStack {
                        formatter.color(gamesVM.finishedCategories[i] ? .primaryFG : .primaryAccent)
                        Text("\(gamesVM.finishedCategories[i] ? "" : category.uppercased())")
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
            .frame(height: 130)
            .padding(.bottom, 5)

            // grid where the clue magic happens
            HStack (spacing: 7) {
                ForEach(0..<gamesVM.categories.count, id: \.self) { i in
                    VStack (spacing: 7) {
                        ForEach(0..<gamesVM.pointValueArray.count, id: \.self) { j in
                            let clueCounts: Int = gamesVM.clues[i].count
                            let responsesCounts: Int = gamesVM.responses[i].count
                            let gridClue: String = clueCounts - 1 >= j ? gamesVM.clues[i][j] : ""
                            let gridResponse: String = responsesCounts - 1 >= j ? gamesVM.responses[i][j] : ""
                            GameCellView(gridClue: gridClue, j: j)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(formatter.cornerRadius(iPadSize: 5))
                                .shadow(color: Color.black.opacity(0.2), radius: 10)
                                .onTapGesture {
                                    gameCellTapped(gridClue: gridClue, gridResponse: gridResponse, i: i, j: j)
                                }
                                .onLongPressGesture {
                                    gamesVM.modifyFinishedClues2D(categoryIndex: i, clueIndex: j, newBool: false)
                                }
                        }
                    }
                }
            }
        }
    }
    
    func gameCellTapped(gridClue: String, gridResponse: String, i: Int, j: Int) {
        if !(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty) {
            unsolved = false
            updateDailyDouble(i: i, j: j)
            updateTripleStumper(i: i, j: j)
            clue = gridClue
            response = gridResponse
            amount = Int(gamesVM.pointValueArray[j]) ?? 0
            category = gamesVM.categories[i]
            value = gamesVM.pointValueArray[j]
            
            participantsVM.setDefaultIndex()
            gamesVM.gameplayDisplay = .clue
            
            if !isDailyDouble {
                formatter.speaker.speak(clue)
            }
        }
    }
    
    func updateDailyDouble(i: Int, j: Int) {
        let toCheck: [Int] = [j, i]
        if gamesVM.gamePhase == .round1 {
            isDailyDouble = toCheck == gamesVM.customSet.roundOneDaily
        } else if gamesVM.gamePhase == .round2 {
            isDailyDouble = (toCheck == gamesVM.customSet.roundTwoDaily1 || toCheck == gamesVM.customSet.roundTwoDaily2)
        }
    }
    
    func updateTripleStumper(i: Int, j: Int) {
        let toCheck: [Int] = [i, j]
        if gamesVM.gamePhase == .round1 {
            isTripleStumper = gamesVM.round1TripleStumpers.contains(toCheck)
        } else if gamesVM.gamePhase == .round2 {
            isTripleStumper = gamesVM.round2TripleStumpers.contains(toCheck)
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
            Text("$\(gamesVM.pointValueArray[j])")
                .font(formatter.font(.extraBold, fontSize: .large))
                .foregroundColor(formatter.color(.secondaryAccent))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                .multilineTextAlignment(.center)
                .opacity(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty ? 0 : 1)
                .minimumScaleFactor(0.1)
        }
        .cornerRadius(10)
    }
}
