//
//  MobileGameGrid.swift
//  Trivio!
//
//  Created by David Chen on 7/24/21.
//

import Foundation
import SwiftUI

struct MobileGameGridView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    @EnvironmentObject var participantsVM: ParticipantsViewModel
    
    @Binding var clueString: String
    @Binding var pointValueString: String
    @Binding var responseString: String
    @Binding var amount: Int
    @Binding var unsolved: Bool
    @Binding var isDailyDouble: Bool
    @Binding var isTripleStumper: Bool
    @Binding var allDone: Bool
    @Binding var showInfoView: Bool
    @Binding var category: String
    
    var body: some View {
        VStack (spacing: 0) {
            HStack (spacing: 5) {
                // Category name
                ForEach(0..<(gamesVM.gamePhase == .round1 ? gamesVM.tidyCustomSet.round1Cats.count : gamesVM.tidyCustomSet.round2Cats.count), id: \.self) { i in
                    let category: String = gamesVM.gamePhase == .round1 ? gamesVM.tidyCustomSet.round1Cats[i] : gamesVM.tidyCustomSet.round2Cats[i]
                    
                    ZStack {
                        formatter.color(gamesVM.categoryDone(colIndex: i) ? .primaryFG : .primaryAccent)
                        Text("\(gamesVM.categoryDone(colIndex: i) ? "" : category.uppercased())")
                            .font(formatter.font(.bold, fontSize: .medium))
                            .foregroundColor(formatter.color(.highContrastWhite))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .minimumScaleFactor(0.1)
                    }
                    .frame(width: 160, height: 90)
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 5)

            // grid where the clue magic happens
            HStack (spacing: 5) {
                Spacer()
                    .frame(width: 12)
                ForEach(0..<(gamesVM.gamePhase == .round1 ? gamesVM.tidyCustomSet.round1Cats.count : gamesVM.tidyCustomSet.round2Cats.count), id: \.self) { i in
                    // i represents column index
                    VStack (spacing: 4) {
                        ForEach(0..<gamesVM.pointValueArray.count, id: \.self) { j in
                            // j represents row index
                            let clueCounts: Int = gamesVM.clues[i].count
                            let responsesCounts: Int = gamesVM.responses[i].count
                            let gridClue: String = clueCounts - 1 >= j ? gamesVM.clues[i][j] : ""
                            let gridResponse: String = responsesCounts - 1 >= j ? gamesVM.responses[i][j] : ""
                            
                            MobileGameCellView(gridClue: gridClue, j: j)
                                .frame(width: 160)
                                .frame(maxHeight: .infinity)
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
                Spacer()
                    .frame(width: 12)
            }
        }
    }
    
    // this is ancient code that needs to go now
    func gameCellTapped(gridClue: String, gridResponse: String, i: Int, j: Int) {
        if !(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty) {
            formatter.hapticFeedback(style: .rigid)
            gamesVM.addToCompletes(colIndex: i)
            unsolved = false
            updateDailyDouble(i: i, j: j)
            updateTripleStumper(i: i, j: j)
            clueString = gridClue
            responseString = gridResponse
            amount = Int(gamesVM.pointValueArray[j]) ?? 0 
            category = gamesVM.categories[i]
            pointValueString = gamesVM.pointValueArray[j]
            
            participantsVM.setDefaultIndex()
            gamesVM.gameplayDisplay = .clue
            gamesVM.currentCategoryIndex = i
            
            if !isDailyDouble {
                formatter.speaker.speak(clueString)
            }
        }
    }
    
    func updateDailyDouble(i: Int, j: Int) {
        let toCheck: [Int] = gamesVM.queriedUserName.isEmpty ? [j, i] : [i, j]
        if gamesVM.gamePhase == .round1 {
            isDailyDouble = toCheck == gamesVM.jeopardyDailyDoubles
        } else if gamesVM.gamePhase == .round2 {
            isDailyDouble = (toCheck == gamesVM.djDailyDoubles1 || toCheck == gamesVM.djDailyDoubles2)
        }
    }
    
    func updateTripleStumper(i: Int, j: Int) {
        let toCheck: [Int] = [i, j]
        if gamesVM.gamePhase == .round1 {
            isTripleStumper = gamesVM.jTripleStumpers.contains(toCheck)
        } else if gamesVM.gamePhase == .round2 {
            isTripleStumper = gamesVM.djTripleStumpers.contains(toCheck)
        }
    }
}

struct MobileGameCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    var gridClue: String
    var j: Int
    
    var body: some View {
        ZStack {
            formatter.color(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty ? .primaryFG : .primaryAccent)
            Text("\(gamesVM.pointValueArray[j])")
                .font(formatter.font(.bold, fontSize: .jumbo))
                .foregroundColor(formatter.color(.secondaryAccent))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                .multilineTextAlignment(.center)
                .opacity(gamesVM.usedAnswers.contains(gridClue) || gridClue.isEmpty ? 0 : 1)
                .minimumScaleFactor(0.1)
        }
        .cornerRadius(10)
    }
}

