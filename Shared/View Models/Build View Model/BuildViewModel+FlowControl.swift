//
//  BuildViewModel+FlowControl.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation

extension BuildViewModel {
    func back() {
        switch buildStage {
        case .trivioRound:
            buildStage = .details
            currentDisplay = .settings
        case .trivioRoundDD:
            buildStage = .trivioRound
            currentDisplay = .grid
        case .dtRound:
            moneySections = moneySectionsJ
            buildStage = .trivioRoundDD
            currentDisplay = .grid
        case .dtRoundDD:
            buildStage = .dtRound
            currentDisplay = .grid
        case .finalTrivio:
            if currCustomSet.hasTwoRounds {
                buildStage = .dtRoundDD
            } else {
                buildStage = .trivioRoundDD
            }
            currentDisplay = .grid
        default:
            buildStage = .finalTrivio
            currentDisplay = .finalTrivio
        }
    }
    
    func rectifyNextProhibited() {
        // Can't get this to work, but it's supposed to reconsider mostAdvancedStage
//        mostAdvancedStage = buildStage
    }
    
    func determineMostAdvancedStage() {
        var round1FilledCount = 0
        var round2FilledCount = 0
        for category in jCategories {
            round1FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        for category in djCategories {
            round2FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        
        let detailsCheck = !self.currCustomSet.tags.isEmpty && !self.currCustomSet.title.isEmpty
        let trivioRoundCheck = round1FilledCount >= self.currCustomSet.round1Len
        let dtRoundCheck = round2FilledCount >= self.currCustomSet.round2Len
        let roundOneDailyCheck = !self.currCustomSet.roundOneDaily.isEmpty
        let roundTwoDailyCheck = !self.currCustomSet.roundTwoDaily1.isEmpty && !self.currCustomSet.roundTwoDaily2.isEmpty
        let finalCheck = !self.currCustomSet.finalCat.isEmpty && !self.currCustomSet.finalClue.isEmpty && !self.currCustomSet.finalResponse.isEmpty
        
        var allBools = [detailsCheck, trivioRoundCheck, roundOneDailyCheck, dtRoundCheck, roundTwoDailyCheck, finalCheck]
        if !currCustomSet.hasTwoRounds {
            allBools = [detailsCheck, trivioRoundCheck, roundOneDailyCheck, finalCheck]
        }
        
        for i in allBools.indices {
            let passesCheckAtIndex = allBools[i]
            if passesCheckAtIndex {
                guard let currStage = MobileBuildStageIndexDict().reverseDict[i] else { return }
                // if the current stage (most advanced stage that passes checks) is more advanced than the current buildStage, assign it as the most advanced stage. Otherwise, assign the current buildStage.
                guard let buildStageIndex = MobileBuildStageIndexDict().dict[buildStage] else { return }
                if i > buildStageIndex {
                    mostAdvancedStage = currStage
                } else {
                    mostAdvancedStage = buildStage
                }
            } else {
                return
            }
        }
    }
    
    func checkForSetIsComplete() -> Bool {
        var round1FilledCount = 0
        var round2FilledCount = 0
        for category in jCategories {
            round1FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        for category in djCategories {
            round2FilledCount += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
        }
        
        let detailsCheck = !currCustomSet.tags.isEmpty && !currCustomSet.title.isEmpty
        let trivioRoundCheck = round1FilledCount >= currCustomSet.round1Len
        let dtRoundCheck = round2FilledCount >= currCustomSet.round2Len
        let roundOneDailyCheck = !currCustomSet.roundOneDaily.isEmpty
        let roundTwoDailyCheck = !currCustomSet.roundTwoDaily1.isEmpty && !currCustomSet.roundTwoDaily2.isEmpty
        let finalCheck = !currCustomSet.finalCat.isEmpty && !currCustomSet.finalClue.isEmpty && !currCustomSet.finalResponse.isEmpty
        
        if currCustomSet.hasTwoRounds {
            return detailsCheck && trivioRoundCheck && dtRoundCheck && roundOneDailyCheck && roundTwoDailyCheck && finalCheck
        } else {
            return detailsCheck && trivioRoundCheck && roundOneDailyCheck && finalCheck
        }
    }
    
    func nextPermitted() -> Bool {
        switch buildStage {
        case .details:
            if currCustomSet.tags.isEmpty || currCustomSet.title.isEmpty {
                rectifyNextProhibited()
            }
            return !currCustomSet.tags.isEmpty && !currCustomSet.title.isEmpty
        case .trivioRound:
            var numFilled = 0
            for category in jCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            if numFilled < currCustomSet.round1Len {
                rectifyNextProhibited()
            }
            return numFilled >= currCustomSet.round1Len
        case .dtRound:
            var numFilled = 0
            for category in djCategories {
                numFilled += (!category.name.isEmpty && !categoryEmpty(category: category)) ? 1 : 0
            }
            if numFilled < currCustomSet.round2Len {
                rectifyNextProhibited()
            }
            return numFilled >= currCustomSet.round2Len
        case .trivioRoundDD:
            if currCustomSet.roundOneDaily.isEmpty {
                rectifyNextProhibited()
            }
            return !currCustomSet.roundOneDaily.isEmpty
        case .dtRoundDD:
            if (currCustomSet.roundTwoDaily1.isEmpty  || currCustomSet.roundTwoDaily2.isEmpty) {
                rectifyNextProhibited()
            }
            return (!currCustomSet.roundTwoDaily1.isEmpty && !currCustomSet.roundTwoDaily2.isEmpty)
        default:
            if currCustomSet.finalCat.isEmpty || currCustomSet.finalClue.isEmpty || currCustomSet.finalResponse.isEmpty {
                rectifyNextProhibited()
            }
            return checkForSetIsComplete()
        }
    }
}
