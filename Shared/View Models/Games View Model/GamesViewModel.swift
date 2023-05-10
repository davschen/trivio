//
//  GameViewModel.swift
//  Trivio
//
//  Created by David Chen on 2/3/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class GamesViewModel: ObservableObject {
    @Published var menuChoice: MenuChoice = .explore
    
    @Published var pointValueArray = ["200", "400", "600", "800", "1000"]
    @Published var gameSetupMode: GameSetupMode = .settings
    @Published var gamePhase: GamePhase = .round1
    @Published var gameplayDisplay: GameplayDisplay = .grid
    @Published var finalTrivioStage: FinalTrivioStage = .notBegun
    
    @Published var gamePreviews = [JeopardySetPreview]()
    @Published var jeopardySeasons = [JeopardySeason]()
    
    // Flashcards
    @Published var flashcardClues2D = [[FlashcardClue]]()
    
    // Nested arrays can be indexed into with [categoryIndex][clueIndex]
    @Published var categories = [String]()
    @Published var clues: [[String]] = []
    @Published var responses: [[String]] = []
    @Published var round1TripleStumpers: [[Int]] = []
    @Published var round2TripleStumpers: [[Int]] = []
    
    @Published var selectedSeason = ""
    @Published var finishedClues2D = [[ClueCompletionStatus]]()
    @Published var finishedCategories = [Bool](repeating: false, count: 6)
    @Published var clueMechanics = ClueMechanics()
    
    @Published var customSets = [CustomSetDurian]()
    @Published var customSet = CustomSetDurian()
    @Published var jeopardySet = JeopardySet()
    @Published var liveGameCustomSet = LiveGameCustomSet()
    @Published var liveGamePlayers = [LiveGamePlayer]()
    
    @Published var title = ""
    @Published var queriedUserName = ""
    @Published var playedGames = [String]()
    
    public var currentSelectedClue = Clue()
    public var currentCategoryIndex = 0
    public var categoryCompletes = [Int](repeating: 0, count: 6)
    public var completedCustomSetClues = 0
    public var latestJeopardyDoc: DocumentSnapshot? = nil
    public var listener: ListenerRegistration?
    
    public var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .short
        return df
    }
    
    public var round1PointValues = ["200", "400", "600", "800", "1000"]
    public var round2PointValues = ["400", "800", "1200", "1600", "2000"]
    
    public var db = FirebaseConfigurator.shared.getFirestore()
    
    init() {
        getSeasons()
        fetchMyCustomSets()
    }
    
    // for starting a new game
    func reset() {
        gamePhase = .round1
        clues = MasterHandler().dictToNestedStringArray(dict: customSet.round1Clues)
        responses = MasterHandler().dictToNestedStringArray(dict: customSet.round1Responses)
        generateFinishedClues2D()
        pointValueArray = round1PointValues
        categories = customSet.round1CategoryNames
        finalTrivioStage = .notBegun
        currentCategoryIndex = 0
    }
    
    func moveOntoRound2() {
        gamePhase = .round2
        categories = customSet.round2CategoryNames
        generateFinishedClues2D()
        clues = MasterHandler().dictToNestedStringArray(dict: customSet.round2Clues)
        responses = MasterHandler().dictToNestedStringArray(dict: customSet.round2Responses)
        completedCustomSetClues = countNonEmptyClues(cluesDict: customSet.round2Clues)
        pointValueArray = round2PointValues
        currentCategoryIndex = 0
    }
    
    func setSeason(jeopardySeason: JeopardySeason) {
        selectedSeason = jeopardySeason.id ?? "NID"
    }
    
    func getCountdown(second: Int) -> (lower: Int, upper: Int) {
        let highBound = Int(clueMechanics.numCountdownSeconds * 2)
        if second <= Int(clueMechanics.numCountdownSeconds) {
            return (second, highBound - second)
        } else {
            return (0, 0)
        }
    }
    
    // for clearing your selection
    func clearAll() {
        gamePhase = .round1
        gameSetupMode = .settings
        round1TripleStumpers.removeAll()
        round2TripleStumpers.removeAll()
        customSet = CustomSetDurian()
        clearCategoryDones()
        queriedUserName.removeAll()
    }
    
    func generateFinishedClues2D() {
        let cluesNestedArray = MasterHandler().dictToNestedStringArray(dict: gamePhase == .round1 ? customSet.round1Clues : customSet.round2Clues)
        var finishedClues2D = [[ClueCompletionStatus]]()
        cluesNestedArray.forEach { cluesArray in
            finishedClues2D.append(cluesArray.compactMap { $0.isEmpty ? .empty : .incomplete })
        }
        self.finishedCategories = [Bool](repeating: false, count: finishedClues2D.count)
        self.finishedClues2D = finishedClues2D
    }
    
    func generateFinishedCatsAndClues(cluesNestedDict: [Int: [String]]) {
        var finishedClues2D = [[ClueCompletionStatus]]()
        cluesNestedDict.forEach { (key, cluesArray) in
            finishedClues2D.append(cluesArray.compactMap { $0.isEmpty ? .empty : .incomplete })
        }
        self.finishedCategories = [Bool](repeating: false, count: finishedClues2D.count)
        self.finishedClues2D = finishedClues2D
    }
    
    func modifyFinishedClues2D(categoryIndex: Int, clueIndex: Int, completed: Bool = true) {
        if finishedClues2D[categoryIndex][clueIndex] == .empty { return }
        finishedClues2D[categoryIndex][clueIndex] = completed ? .complete : .incomplete
        // this tricky piece of code marks a category as finished if all of its clues are finished
        finishedCategories[categoryIndex] = finishedClues2D[categoryIndex].allSatisfy({$0 != .incomplete})
    }
    
    func getNumCompletedClues() -> Int {
        return finishedClues2D.joined().filter{$0 == .complete}.count
    }
    
    func timerBlockIsUnlit(timeElapsed: Double, blockIndex: Int) -> Bool {
        let maxIndex = 8
        if timeElapsed <= 0 { return false }
        if timeElapsed > (Double(maxIndex) / 2.0) + 1 { return true }
        let a = 0
        let b = maxIndex
        let adjustedTimeElapsed = Int(timeElapsed - 1)
        return (blockIndex <= a + adjustedTimeElapsed) || (blockIndex >= b - adjustedTimeElapsed)
    }
    
    func getCurrentSelectedClue() -> Clue {
        return currentSelectedClue
    }
    
    func setCurrentSelectedClue(categoryIndex: Int, clueIndex: Int) {
        gameplayDisplay = .clue
        
        let clueCounts: Int = clues[categoryIndex].count
        let responsesCounts: Int = responses[categoryIndex].count
        let clueString: String = clueCounts - 1 >= clueIndex ? clues[categoryIndex][clueIndex] : ""
        let responseString: String = responsesCounts - 1 >= clueIndex ? responses[categoryIndex][clueIndex] : ""
        let pointValueInt = Int(pointValueArray[clueIndex]) ?? 0
        
        currentSelectedClue = Clue(categoryString: categories[categoryIndex], clueString: clueString, responseString: responseString, isDailyDouble: clueIsDailyDouble(categoryIndex: categoryIndex, clueIndex: clueIndex), isTripleStumper: clueIsTripleStumper(categoryIndex: categoryIndex, clueIndex: clueIndex), pointValueInt: pointValueInt)
        
        modifyFinishedClues2D(categoryIndex: categoryIndex, clueIndex: clueIndex)
        currentCategoryIndex = categoryIndex
    }
    
    func clueIsDailyDouble(categoryIndex: Int, clueIndex: Int) -> Bool {
        // Check if this is a Jeopardy-made set or not...
        let toCheck: [Int] = customSet.userID.isEmpty ? [clueIndex, categoryIndex] : [categoryIndex, clueIndex]
        if gamePhase == .round1 {
            return toCheck == customSet.roundOneDaily
        } else {
            return (toCheck == customSet.roundTwoDaily1 || toCheck == customSet.roundTwoDaily2)
        }
    }
    
    func clueIsTripleStumper(categoryIndex: Int, clueIndex: Int) -> Bool {
        let toCheck: [Int] = [categoryIndex, clueIndex]
        if gamePhase == .round1 {
            return round1TripleStumpers.contains(toCheck)
        } else {
            return round2TripleStumpers.contains(toCheck)
        }
    }
    
    func progressGame() {
        gameplayDisplay = .grid
        clueMechanics.resetAllVariables()
        if doneWithRound() {
            if gamePhase == .round1 && customSet.hasTwoRounds {
                moveOntoRound2()
            } else {
                gamePhase = .finalRound
            }
        }
    }
    
    func doneWithRound() -> Bool {
        if gamePhase != .finalRound {
            return finishedCategories.allSatisfy({ $0 })
        } else {
            return false
        }
    }
    
    func clearCategoryDones() {
        for i in 0..<self.categoryCompletes.count {
            categoryCompletes[i] = 0
        }
    }
    
    func gameInProgress() -> Bool {
        if gamePhase == .round1 && finishedClues2D.joined().filter({$0 == .complete}).count == 0 {
            return false
        } else {
            return true
        }
    }
}

enum ClueCompletionStatus {
    case empty, incomplete, complete
}

enum GameSetupMode {
    case settings, participants, play
}

enum GamePhase: CaseIterable {
    case round1, round2, finalRound
}

enum GameplayDisplay {
    case grid, clue
}

struct ClueMechanics {
    var showResponse: Bool = false
    var wvcWagerMade: Bool = false
    var numCountdownSeconds: Double = 5
    var timeElapsed: Double = 0
    var wvcWager: Double = 0
    
    mutating func resetAllVariables() {
        timeElapsed = 0
        wvcWager = 0
        wvcWagerMade = false
        showResponse = false
    }
    
    mutating func makeWVCWager(wager: Double = 0) {
        wvcWager = wager
        wvcWagerMade.toggle()
    }
    
    mutating func toggleShowResponse() {
        showResponse.toggle()
    }
    
    mutating func setTimeElapsed(newValue: Double) {
        timeElapsed = newValue
    }
}
