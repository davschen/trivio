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
                        formatter.color(gamesVM.categoryDone(colIndex: i) ? .primaryFG : .primaryAccent)
                        Text("\(gamesVM.categoryDone(colIndex: i) ? "" : category.uppercased())")
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
                        ForEach(0..<gamesVM.moneySections.count, id: \.self) { j in
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
                                    if gamesVM.usedAnswers.contains(gridClue) && !gridClue.isEmpty {
                                        gamesVM.removeAnswer(answer: gridClue)
                                        gamesVM.removeFromCompletes(colIndex: i)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    func gameCellTapped(gridClue: String, gridResponse: String, i: Int, j: Int) {
        if !(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty) {
            gamesVM.addToCompletes(colIndex: i)
            unsolved = false
            updateDailyDouble(i: i, j: j)
            updateTripleStumper(i: i, j: j)
            clue = gridClue
            response = gridResponse
            amount = Int(gamesVM.moneySections[j]) ?? 0
            category = gamesVM.categories[i]
            value = gamesVM.moneySections[j]
            
            participantsVM.setDefaultIndex()
            gamesVM.gameplayDisplay = .clue
            
            if !isDailyDouble {
                formatter.speaker.speak(clue)
            }
        }
    }
    
    func updateDailyDouble(i: Int, j: Int) {
        let toCheck: [Int] = [j, i]
        if gamesVM.gamePhase == .trivio {
            isDailyDouble = toCheck == gamesVM.jeopardyDailyDoubles
        } else if gamesVM.gamePhase == .doubleTrivio {
            isDailyDouble = (toCheck == gamesVM.djDailyDoubles1 || toCheck == gamesVM.djDailyDoubles2)
        }
    }
    
    func updateTripleStumper(i: Int, j: Int) {
        let toCheck: [Int] = [i, j]
        if gamesVM.gamePhase == .trivio {
            isTripleStumper = gamesVM.jTripleStumpers.contains(toCheck)
        } else if gamesVM.gamePhase == .doubleTrivio {
            isTripleStumper = gamesVM.djTripleStumpers.contains(toCheck)
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
    }
}
