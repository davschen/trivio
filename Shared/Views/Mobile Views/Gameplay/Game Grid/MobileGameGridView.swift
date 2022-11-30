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
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            VStack (spacing: 0) {
                // Horizontal arrangement of category names
                HStack (spacing: 5) {
                    ForEach(0..<(gamesVM.gamePhase == .round1 ? gamesVM.tidyCustomSet.round1Cats.count : gamesVM.tidyCustomSet.round2Cats.count), id: \.self) { i in
                        let category: String = gamesVM.gamePhase == .round1 ? gamesVM.tidyCustomSet.round1Cats[i] : gamesVM.tidyCustomSet.round2Cats[i]
                        
                        ZStack {
                            formatter.color(gamesVM.finishedCategories[i] ? .primaryFG : .primaryAccent)
                            Text("\(gamesVM.finishedCategories[i] ? "" : category.uppercased())")
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

                // Clues grid
                HStack (spacing: 5) {
                    Spacer()
                        .frame(width: 12)
                    ForEach(gamesVM.categories.indices, id: \.self) { categoryIndex in
                        VStack (spacing: 4) {
                            ForEach(0..<gamesVM.pointValueArray.count, id: \.self) { clueIndex in
                                MobileGameCellView(categoryIndex: categoryIndex, clueIndex: clueIndex)
                                    .frame(width: 160)
                                    .frame(maxHeight: .infinity)
                                    .shadow(color: Color.black.opacity(0.2), radius: 10)
                                    .onTapGesture {
                                        gameCellTapped(categoryIndex: categoryIndex, clueIndex: clueIndex)
                                    }
                                    .onLongPressGesture {
                                        gamesVM.modifyFinishedClues2D(categoryIndex: categoryIndex, clueIndex: clueIndex, completed: false)
                                    }
                            }
                        }
                    }
                    Spacer()
                        .frame(width: 12)
                }
            }
        }
    }
    
    func gameCellTapped(categoryIndex: Int, clueIndex: Int) {
        if gamesVM.finishedClues2D[categoryIndex][clueIndex] == .incomplete {
            formatter.hapticFeedback(style: .rigid)
            gamesVM.setCurrentSelectedClue(categoryIndex: categoryIndex, clueIndex: clueIndex)
            participantsVM.setDefaultIndex()
            
            if !gamesVM.currentSelectedClue.isDailyDouble {
                formatter.speaker.speak(gamesVM.currentSelectedClue.clueString)
            }
        }
    }
}

struct MobileGameCellView: View {
    @EnvironmentObject var formatter: MasterHandler
    @EnvironmentObject var gamesVM: GamesViewModel
    
    let categoryIndex: Int
    let clueIndex: Int
    
    var body: some View {
        ZStack {
            formatter.color(isIncomplete() ? .primaryAccent : .primaryFG)
            Text("\(gamesVM.pointValueArray[clueIndex])")
                .font(formatter.font(.bold, fontSize: .jumbo))
                .foregroundColor(formatter.color(.secondaryAccent))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
                .multilineTextAlignment(.center)
                .opacity(isIncomplete() ? 1 : 0)
                .minimumScaleFactor(0.1)
        }
        .cornerRadius(10)
    }
    
    func isIncomplete() -> Bool {
        if categoryIndex >= gamesVM.categories.count {
            return false
        }
        return gamesVM.finishedClues2D[categoryIndex][clueIndex] == .incomplete
    }
}

